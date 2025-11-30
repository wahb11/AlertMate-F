class Vehicle {
  final String id;
  final String make;
  final String model;
  final String year;
  final String licensePlate;
  final String? ownerId;
  final String? assignedDriverId;
  final String? assignedDriverEmail;
  final String? driverName;
  final String status;
  final String alertness;
  final String? location;
  final String? lastUpdate;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.ownerId,
    this.assignedDriverId,
    this.assignedDriverEmail,
    this.driverName,
    this.status = 'Offline',
    this.alertness = 'Good',
    this.location,
    this.lastUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'ownerId': ownerId,
      'assignedDriverId': assignedDriverId,
      'assignedDriverEmail': assignedDriverEmail,
      'driverName': driverName,
      'status': status,
      'alertness': alertness,
      'location': location,
      'lastUpdate': lastUpdate,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      ownerId: map['ownerId'],
      assignedDriverId: map['assignedDriverId'],
      assignedDriverEmail: map['assignedDriverEmail'],
      driverName: map['driverName'],
      status: map['status'] ?? 'Offline',
      alertness: map['alertness'] ?? 'Good',
      location: map['location'] ?? 'Unknown',
      lastUpdate: map['lastUpdate'] ?? 'N/A',
    );
  }
}
