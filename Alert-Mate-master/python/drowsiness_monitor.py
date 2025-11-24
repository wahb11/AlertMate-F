import argparse
import json
import sys
import time

import cv2
import numpy as np
from tensorflow.keras.models import load_model


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True, help="Path to Keras model (.h5 or SavedModel dir)")
    parser.add_argument("--size", type=int, default=128, help="Input size (square)")
    parser.add_argument("--camera", type=int, default=0, help="Camera index")
    args = parser.parse_args()

    model = load_model(args.model)

    cap = cv2.VideoCapture(args.camera)
    if not cap.isOpened():
        print(json.dumps({"error": "Could not open camera"}), flush=True)
        sys.exit(1)

    last_stats_time = 0.0

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print(json.dumps({"error": "Failed to read frame"}), flush=True)
                break

            img = cv2.resize(frame, (args.size, args.size))
            img = img / 255.0
            img = np.expand_dims(img, axis=0)

            pred = float(model.predict(img, verbose=0)[0][0])
            label = "Drowsy" if pred < 0.5 else "Non-Drowsy"

            # Fake auxiliary metrics (replace with real EAR/MAR if available)
            ear = max(0.0, min(1.0, 1.0 - pred))
            mar = max(0.0, min(1.0, pred))
            eye_closure = (1.0 - pred) * 100.0
            alertness = pred * 100.0

            # Draw label
            cv2.putText(frame, label, (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255) if label == "Drowsy" else (0, 200, 0), 2)
            cv2.imshow("Drowsiness Detection", frame)

            # Emit stats at ~10 Hz
            t = time.time()
            if t - last_stats_time > 0.1:
                last_stats_time = t
                print(json.dumps({
                    "label": label,
                    "alertness": alertness,
                    "ear": ear,
                    "mar": mar,
                    "eyeClosure": eye_closure,
                }), flush=True)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    finally:
        cap.release()
        cv2.destroyAllWindows()


if __name__ == "__main__":
    main()


