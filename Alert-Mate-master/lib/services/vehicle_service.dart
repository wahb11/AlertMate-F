import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vehicles';

  factory VehicleService() {
    return _instance;
  }

  VehicleService._internal();

  // No mock data needed anymore

  // Get vehicles stream for an owner
  Stream<List<Vehicle>> getVehiclesByOwnerStream(String ownerId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList();
    });
  }

  // Get vehicle stream for a driver
  Stream<Vehicle?> getVehicleByDriverStream(String driverId) {
    return _firestore
        .collection(_collection)
        .where('driverId', isEqualTo: driverId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Vehicle.fromMap(snapshot.docs.first.data());
    });
  }

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    // Ensure new vehicles are unassigned initially if not specified
    if (vehicle.driverId == null || vehicle.driverId!.isEmpty) {
      vehicle.status = 'Offline';
    }
    
    await _firestore.collection(_collection).doc(vehicle.id).set(vehicle.toMap());
  }

  // Assign a specific driver to a vehicle
  Future<void> assignDriver(String vehicleId, String driverId, String driverName) async {
    await _firestore.collection(_collection).doc(vehicleId).update({
      'driverId': driverId,
      'driverName': driverName,
      'status': 'Active',
    });
  }

  // Auto-assign an available vehicle to a driver
  Future<Vehicle?> assignAvailableVehicleToDriver(String driverId, String driverName) async {
    try {
      // 1. Check if driver already has a vehicle
      final existingQuery = await _firestore
          .collection(_collection)
          .where('driverId', isEqualTo: driverId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        return Vehicle.fromMap(existingQuery.docs.first.data());
      }

      // 2. Find first unassigned vehicle (driverId is null or empty)
      // Note: Firestore doesn't support OR queries on the same field easily in one go for null/empty
      // We will look for vehicles where driverId is null first
      var querySnapshot = await _firestore
          .collection(_collection)
          .where('driverId', isNull: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Try empty string
        querySnapshot = await _firestore
            .collection(_collection)
            .where('driverId', isEqualTo: '')
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        final vehicleDoc = querySnapshot.docs.first;
        final vehicle = Vehicle.fromMap(vehicleDoc.data());

        // 3. Assign it
        await _firestore.collection(_collection).doc(vehicle.id).update({
          'driverId': driverId,
          'driverName': driverName,
          'status': 'Active',
        });

        // Return updated vehicle
        vehicle.driverId = driverId;
        vehicle.driverName = driverName;
        vehicle.status = 'Active';
        return vehicle;
      }
      
      return null; // No vehicles available
    } catch (e) {
      print('Error assigning vehicle: $e');
      return null;
    }
  }
  
  // Helper to generate ID
  String generateVehicleId() {
    return _firestore.collection(_collection).doc().id;
  }
  
  // Initialize mock data if collection is empty (optional, for testing)
  Future<void> initMockData(String ownerId) async {
    final snapshot = await _firestore.collection(_collection).limit(1).get();
    if (snapshot.docs.isEmpty) {
      await addVehicle(Vehicle(
        id: generateVehicleId(),
        make: 'Toyota',
        model: 'Camry',
        year: '2022',
        licensePlate: 'ABC-123',
        ownerId: ownerId,
        status: 'Offline',
        alertness: 100,
        location: 'HQ',
        lastUpdate: 'Just now',
      ));
      await addVehicle(Vehicle(
        id: generateVehicleId(),
        make: 'Honda',
        model: 'Civic',
        year: '2021',
        licensePlate: 'XYZ-789',
        ownerId: ownerId,
        status: 'Offline',
        alertness: 100,
        location: 'HQ',
        lastUpdate: 'Just now',
      ));
    }
  }
}
