class Vehicle {
  final String id;
  final String make;
  final String model;
  final String year;
  final String licensePlate;
  String? driverId;
  String? driverName;
  final String ownerId;
  String status;
  int alertness;
  String location;
  String lastUpdate;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.ownerId,
    this.driverId,
    this.driverName,
    this.status = 'Offline',
    this.alertness = 100,
    this.location = 'Unknown',
    this.lastUpdate = 'Just now',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'driverId': driverId,
      'driverName': driverName,
      'ownerId': ownerId,
      'status': status,
      'alertness': alertness,
      'location': location,
      'lastUpdate': lastUpdate,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      make: map['make'],
      model: map['model'],
      year: map['year'],
      licensePlate: map['licensePlate'],
      ownerId: map['ownerId'],
      driverId: map['driverId'],
      driverName: map['driverName'],
      status: map['status'] ?? 'Offline',
      alertness: map['alertness'] ?? 100,
      location: map['location'] ?? 'Unknown',
      lastUpdate: map['lastUpdate'] ?? 'Just now',
    );
  }
}
