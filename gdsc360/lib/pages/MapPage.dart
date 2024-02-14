import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdsc360/utils/authservice.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  double currentZoomLevel = 15.0;
  String _address = "Location Tracker"; // Initial AppBar title
  LatLng _currentLatLng = LatLng(0, 0); // Default LatLng

  // Assuming AuthService provides a Future<String?> to get the current user's UID
  Auth auth = Auth();

  @override
  void initState() {
    super.initState();
    _fetchInitialLocation();
  }

  Future<void> _fetchInitialLocation() async {
    String? uid = await auth.getCurrentUserUid();
    if (uid != null) {
      // Assuming AuthService's getUserData now correctly awaits and returns a Future<Map<String, dynamic>>
      Map<String, dynamic>? userData = await auth.getUserData(uid);
      String? partnerId = userData?['partnerID'];
      if (partnerId != null) {
        _listenToPartnerLocation(partnerId);
      }
    }
  }

  void _listenToPartnerLocation(String partnerId) {
    FirebaseFirestore.instance
        .collection('users_location')
        .doc(partnerId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        Position position = Position(
          latitude: data['latitude'],
          longitude: data['longitude'],
          timestamp: DateTime.now(), // Placeholder for actual timestamp
          accuracy: 0.0, // Placeholder values
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0, altitudeAccuracy: 0, headingAccuracy: 0,
        );
        _updateMapLocation(position);
        _updateAddress(LatLng(position.latitude, position.longitude));
      }
    });
  }

  Future<void> _updateMapLocation(Position position) async {
    final GoogleMapController mapController = await _controller.future;
    LatLng newPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLatLng = newPosition;
    });

    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: newPosition,
        zoom: currentZoomLevel,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _address,
          style: TextStyle(fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        automaticallyImplyLeading: false,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng,
          zoom: currentZoomLevel,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("partner"),
            position: _currentLatLng,
            draggable: true,
            onDragEnd: (newPosition) {
              _updateAddress(newPosition);
            },
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onCameraMove: (CameraPosition position) {
          currentZoomLevel = position.zoom;
        },
      ),
    );
  }

  Future<void> _updateAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      setState(() {
        _address = '${place.street}, ${place.locality}, ${place.country}';
      });
    } catch (e) {
      setState(() {
        _address = "Unable to determine address";
      });
    }
  }
}
