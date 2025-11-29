import '../models/vehicle.dart';

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();

  factory VehicleService() {
    return _instance;
  }

  VehicleService._internal();

  final List<Vehicle> _vehicles = [];

  // Mock initial data
  void initMockData() {
    if (_vehicles.isEmpty) {
      _vehicles.addAll([
        Vehicle(
          id: 'V001',
          make: 'Toyota',
          model: 'Camry',
          year: '2022',
          licensePlate: 'ABC-123',
          ownerId: 'owner1',
          driverId: 'driver1', 
          driverName: 'John Smith',
          status: 'Active',
          alertness: 85,
          location: 'Highway 101',
          lastUpdate: '2 min ago',
        ),
        Vehicle(
          id: 'V002',
          make: 'Honda',
          model: 'Civic',
          year: '2021',
          licensePlate: 'XYZ-789',
          ownerId: 'owner1',
          driverId: 'driver2',
          driverName: 'Sarah Johnson',
          status: 'Break',
          alertness: 92,
          location: 'Rest Area',
          lastUpdate: '15 min ago',
        ),
      ]);
    }
  }

  List<Vehicle> getVehiclesByOwner(String ownerId) {
    // For now, return all vehicles since we don't have real auth IDs everywhere
    return _vehicles; 
  }

  Vehicle? getVehicleByDriver(String driverId) {
    try {
      return _vehicles.firstWhere((v) => v.driverId == driverId);
    } catch (e) {
      return null;
    }
  }

  void addVehicle(Vehicle vehicle) {
    // Only set defaults if vehicle is not already assigned
    if (vehicle.driverId == null || vehicle.driverId!.isEmpty) {
      vehicle.status = 'Offline';
    }
    _vehicles.add(vehicle);
  }

  void assignDriver(String vehicleId, String driverId, String driverName) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index].driverId = driverId;
      _vehicles[index].driverName = driverName;
      _vehicles[index].status = 'Active'; // Activate when assigned
    }
  }

  // Auto-assign an available vehicle to a driver
  Vehicle? assignAvailableVehicleToDriver(String driverId, String driverName) {
    // Check if driver already has a vehicle
    if (getVehicleByDriver(driverId) != null) {
      return getVehicleByDriver(driverId);
    }

    try {
      // Find first unassigned vehicle
      final availableVehicle = _vehicles.firstWhere((v) => v.driverId == null || v.driverId!.isEmpty);
      availableVehicle.driverId = driverId;
      availableVehicle.driverName = driverName;
      availableVehicle.status = 'Active';
      return availableVehicle;
    } catch (e) {
      return null; // No vehicles available
    }
  }
  
  // Helper to generate ID
  String generateVehicleId() {
    return 'V${(_vehicles.length + 1).toString().padLeft(3, '0')}';
  }
}
