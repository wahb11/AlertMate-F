import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import 'firebase_auth_service.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Generate unique vehicle ID
  String generateVehicleId() {
    return 'VEH_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Add vehicle with driver assignment option
  Future<Vehicle?> addVehicleWithDriverCheck({
    required String make,
    required String model,
    required String year,
    required String licensePlate,
    required String ownerId,
    required String ownerEmail,
    required bool willOwnerDrive,
  }) async {
    try {
      print('🚗 Adding vehicle: $make $model');
      
      DocumentReference vehicleRef = await _firestore.collection('vehicles').add({
        'make': make,
        'model': model,
        'year': year,
        'licensePlate': licensePlate,
        'ownerId': ownerId,
        'ownerEmail': ownerEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Offline',
        'alertness': 'Good',
        'location': 'Unknown',
      });

      print('✅ Vehicle created: ${vehicleRef.id}');
      
      if (willOwnerDrive) {
        print('👤 Owner indicated they will drive this vehicle');
        
        bool isDriverRegistered = await _isUserRegisteredAsDriver(ownerId);
        
        if (isDriverRegistered) {
          print('✅ Owner is registered as driver. Auto-assigning vehicle...');
          
          await assignVehicleToDriver(
            vehicleId: vehicleRef.id,
            driverId: ownerId,
            driverEmail: ownerEmail,
          );
          
          print('✅ Vehicle auto-assigned to driver!');
          return Vehicle(
            id: vehicleRef.id,
            make: make,
            model: model,
            year: year,
            licensePlate: licensePlate,
            ownerId: ownerId,
            assignedDriverId: ownerId,
            status: 'Active',
          );
        } else {
          print('❌ Owner is NOT registered as driver');
          return null;
        }
      }
      
      return Vehicle(
        id: vehicleRef.id,
        make: make,
        model: model,
        year: year,
        licensePlate: licensePlate,
        ownerId: ownerId,
      );
    } catch (e) {
      print('❌ Error adding vehicle: $e');
      rethrow;
    }
  }

  // Check if user is registered as driver
  Future<bool> _isUserRegisteredAsDriver(String userId) async {
    try {
      print('🔍 Checking if user $userId is registered as driver...');
      
      DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<String> roles = List<String>.from(data['roles'] ?? []);
        bool isDriver = roles.contains('driver');
        
        print(isDriver ? '✅ User is a driver' : '❌ User is not a driver');
        return isDriver;
      }
      
      print('❌ User document not found');
      return false;
    } catch (e) {
      print('❌ Error checking driver registration: $e');
      return false;
    }
  }

  // Assign vehicle to driver
  Future<void> assignVehicleToDriver({
    required String vehicleId,
    required String driverId,
    required String driverEmail,
  }) async {
    try {
      print('🔗 Assigning vehicle $vehicleId to driver $driverId');
      
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'assignedDriverId': driverId,
        'assignedDriverEmail': driverEmail,
        'assignedAt': FieldValue.serverTimestamp(),
        'status': 'Active',
      });

      await _firestore.collection('vehicleAssignments').add({
        'vehicleId': vehicleId,
        'driverId': driverId,
        'driverEmail': driverEmail,
        'assignedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      print('✅ Vehicle assigned to driver successfully!');
    } catch (e) {
      print('❌ Error assigning vehicle: $e');
      rethrow;
    }
  }

  // Assign available vehicle to driver (for auth flow)
  Future<void> assignAvailableVehicleToDriver(String driverId, String driverName) async {
    try {
      print('🚗 Looking for available vehicles for driver: $driverName');
      
      DocumentSnapshot driverDoc = 
          await _firestore.collection('users').doc(driverId).get();
      
      if (!driverDoc.exists) {
        print('❌ Driver document not found');
        return;
      }

      Map<String, dynamic> driverData = driverDoc.data() as Map<String, dynamic>;
      String driverEmail = driverData['email'] ?? '';

      QuerySnapshot unassignedVehicles = await _firestore
          .collection('vehicles')
          .where('ownerId', isEqualTo: driverId)
          .where('assignedDriverId', isNull: true)
          .limit(1)
          .get();

      if (unassignedVehicles.docs.isNotEmpty) {
        String vehicleId = unassignedVehicles.docs.first.id;
        
        await assignVehicleToDriver(
          vehicleId: vehicleId,
          driverId: driverId,
          driverEmail: driverEmail,
        );
        
        print('✅ Vehicle auto-assigned to new driver!');
      } else {
        print('⚠️ No unassigned vehicles found for this driver');
      }
    } catch (e) {
      print('❌ Error assigning available vehicle: $e');
    }
  }

  // Get vehicles assigned to driver
  Future<List<Vehicle>> getAssignedVehiclesForDriver(String driverId) async {
    try {
      print('🚗 Fetching vehicles for driver: $driverId');
      
      QuerySnapshot snapshot = await _firestore
          .collection('vehicles')
          .where('assignedDriverId', isEqualTo: driverId)
          .get();

      List<Vehicle> vehicles = snapshot.docs
          .map((doc) => Vehicle.fromMap({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }))
          .toList();

      print('✅ Found ${vehicles.length} vehicles for driver');
      return vehicles;
    } catch (e) {
      print('❌ Error fetching driver vehicles: $e');
      return [];
    }
  }

  // Get all vehicles for owner
  Future<List<Vehicle>> getVehiclesForOwner(String ownerId) async {
    try {
      print('🚗 Fetching vehicles for owner: $ownerId');
      
      QuerySnapshot snapshot = await _firestore
          .collection('vehicles')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      List<Vehicle> vehicles = snapshot.docs
          .map((doc) => Vehicle.fromMap({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }))
          .toList();

      print('✅ Found ${vehicles.length} vehicles for owner');
      return vehicles;
    } catch (e) {
      print('❌ Error fetching owner vehicles: $e');
      return [];
    }
  }

  // Get single vehicle stream for driver (returns first vehicle)
  Stream<Vehicle?> getVehicleByDriverStream(String driverId) {
    try {
      print('📡 Streaming vehicle for driver: $driverId');
      
      return _firestore
          .collection('vehicles')
          .where('assignedDriverId', isEqualTo: driverId)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          Vehicle vehicle = Vehicle.fromMap({
            'id': snapshot.docs.first.id,
            ...snapshot.docs.first.data() as Map<String, dynamic>,
          });
          print('✅ Driver vehicle stream updated');
          return vehicle;
        }
        print('⚠️ No vehicle found for driver');
        return null;
      });
    } catch (e) {
      print('❌ Error getting driver vehicle stream: $e');
      return Stream.value(null);
    }
  }

  // Get vehicles stream for owner (returns list)
  Stream<List<Vehicle>> getVehiclesByOwnerStream(String ownerId) {
    try {
      print('📡 Streaming vehicles for owner: $ownerId');
      
      return _firestore
          .collection('vehicles')
          .where('ownerId', isEqualTo: ownerId)
          .snapshots()
          .map((snapshot) {
        List<Vehicle> vehicles = snapshot.docs
            .map((doc) => Vehicle.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
            .toList();
        
        print('✅ Owner vehicles stream: ${vehicles.length} vehicles');
        return vehicles;
      });
    } catch (e) {
      print('❌ Error getting owner vehicle stream: $e');
      return Stream.value([]);
    }
  }

  // Update vehicle status
  Future<void> updateVehicleStatus(String vehicleId, String status) async {
    try {
      print('🔄 Updating vehicle $vehicleId status to: $status');
      
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'status': status,
        'lastUpdate': DateTime.now().toString(),
      });

      print('✅ Vehicle status updated');
    } catch (e) {
      print('❌ Error updating vehicle status: $e');
      rethrow;
    }
  }

  // Update vehicle alertness
  Future<void> updateVehicleAlertness(String vehicleId, String alertness) async {
    try {
      print('🔄 Updating vehicle $vehicleId alertness to: $alertness');
      
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'alertness': alertness,
        'lastUpdate': DateTime.now().toString(),
      });

      print('✅ Vehicle alertness updated');
    } catch (e) {
      print('❌ Error updating vehicle alertness: $e');
      rethrow;
    }
  }

  // Update vehicle location
  Future<void> updateVehicleLocation(String vehicleId, String location) async {
    try {
      print('📍 Updating vehicle $vehicleId location to: $location');
      
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'location': location,
        'lastUpdate': DateTime.now().toString(),
      });

      print('✅ Vehicle location updated');
    } catch (e) {
      print('❌ Error updating vehicle location: $e');
      rethrow;
    }
  }

  // Get vehicle by ID
  Future<Vehicle?> getVehicleById(String vehicleId) async {
    try {
      print('🔍 Fetching vehicle: $vehicleId');
      
      DocumentSnapshot doc = 
          await _firestore.collection('vehicles').doc(vehicleId).get();
      
      if (doc.exists) {
        Vehicle vehicle = Vehicle.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
        
        print('✅ Vehicle found: ${vehicle.make} ${vehicle.model}');
        return vehicle;
      }
      
      print('❌ Vehicle not found');
      return null;
    } catch (e) {
      print('❌ Error fetching vehicle: $e');
      return null;
    }
  }

  // Add vehicle (for backward compatibility)
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      print('🚗 Adding vehicle via addVehicle');
      
      await _firestore.collection('vehicles').doc(vehicle.id).set({
        'make': vehicle.make,
        'model': vehicle.model,
        'year': vehicle.year,
        'licensePlate': vehicle.licensePlate,
        'ownerId': vehicle.ownerId,
        'assignedDriverId': vehicle.assignedDriverId,
        'driverName': vehicle.driverName,
        'status': vehicle.status,
        'alertness': vehicle.alertness,
        'location': vehicle.location,
        'lastUpdate': vehicle.lastUpdate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Vehicle added successfully');
    } catch (e) {
      print('❌ Error adding vehicle: $e');
      rethrow;
    }
  }

  // Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      print('🚗 Fetching all vehicles');
      
      QuerySnapshot snapshot = await _firestore
          .collection('vehicles')
          .get();

      List<Vehicle> vehicles = snapshot.docs
          .map((doc) => Vehicle.fromMap({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }))
          .toList();

      print('✅ Found ${vehicles.length} total vehicles');
      return vehicles;
    } catch (e) {
      print('❌ Error fetching all vehicles: $e');
      return [];
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      print('🗑️ Deleting vehicle: $vehicleId');
      
      await _firestore.collection('vehicles').doc(vehicleId).delete();
      
      print('✅ Vehicle deleted successfully');
    } catch (e) {
      print('❌ Error deleting vehicle: $e');
      rethrow;
    }
  }

  // Unassign vehicle from driver
  Future<void> unassignVehicleFromDriver(String vehicleId) async {
    try {
      print('🔓 Unassigning vehicle: $vehicleId');
      
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'assignedDriverId': FieldValue.delete(),
        'assignedDriverEmail': FieldValue.delete(),
        'status': 'Offline',
      });

      print('✅ Vehicle unassigned successfully');
    } catch (e) {
      print('❌ Error unassigning vehicle: $e');
      rethrow;
    }
  }
}
