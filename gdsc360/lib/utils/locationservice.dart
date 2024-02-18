import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  StreamSubscription<Position>? locationSubscription;
  final _locationController = StreamController<Position>.broadcast();
  final int updateInterval = 5;
  Position? _lastPosition;
  bool isTracking = false;

  Stream<Position> get locationStream => _locationController.stream;

  LocationTrackingService() {
    // Start periodic updates when instance is created
    Timer.periodic(Duration(seconds: updateInterval), (timer) {
      if (_lastPosition != null) {
        saveLocationToFirestore(_lastPosition!);
      }
    });
  }

  void startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("Location tracking permission denied.");
        return; // Exit if permissions are not granted
      }
    }

    // Listen to location changes
    locationSubscription = Geolocator.getPositionStream().listen((position) {
      _locationController.sink.add(position);
      // Store the latest location data
      _lastPosition = position;
    });

    isTracking = true;
  }

  void stopTracking() {
    locationSubscription?.cancel();
    _locationController.close();
    _lastPosition = null;
  }

  void saveLocationToFirestore(Position position) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        // Get address from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        String address = _formatAddress(placemarks.first);

        // Save data to Firestore
        await firestore.collection('users_location').doc(userId).set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': FieldValue.serverTimestamp(),
          'address': address,
        });
        print("Location saved to Firestore for user $userId.");
        print("Address is at $address");
      } catch (e) {
        print("Error saving location to Firestore: $e");
      }
    }
  }

  // Helper function to format the address from Placemark
  String _formatAddress(Placemark placemark) {
    return '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
  }

  Stream<Position> getPartnerLocationStream(String partnerId) {
    return FirebaseFirestore.instance
        .collection('users_location')
        .doc(partnerId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return Position(
            latitude: 0.0,
            longitude: 0.0,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0,
            headingAccuracy:
                0); // Return a default position if the document does not exist
      }
      var data = snapshot.data();
      return Position(
        latitude: data!['latitude'],
        longitude: data['longitude'],
        timestamp: DateTime
            .now(), // Firestore timestamps are not directly compatible with Position timestamp
        accuracy: 0.0, // Optional: Adjust these fields as necessary
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0, altitudeAccuracy: 0, headingAccuracy: 0,
      );
    });
  }
}
