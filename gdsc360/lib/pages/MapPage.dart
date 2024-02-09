import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gdsc360/utils/locationservice.dart'; // Update this to use geolocator
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator
import 'package:geocoding/geocoding.dart'; // Import geocoding for reverse geocoding

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationTrackingService locationTrackingService =
      LocationTrackingService(); // Ensure this is using geolocator

  double currentZoomLevel = 15.0;
  String _address = "Location Tracker"; // Initial AppBar title
  LatLng _currentLatLng = LatLng(0, 0); // Default LatLng

  @override
  void initState() {
    super.initState();
    locationTrackingService.startTracking();
  }

  @override
  void dispose() {
    locationTrackingService.stopTracking();
    super.dispose();
  }

  Future<void> updateMapLocation(Position position) async {
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

    await _updateAddress(newPosition);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _address,
          style: TextStyle(fontSize: 16), // Set a smaller font size
          maxLines: 2, // Maximum of 2 lines
          overflow: TextOverflow.ellipsis, // Add ellipsis for text overflow
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<Position>(
        stream: locationTrackingService.locationStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Initial update of map location
            if (_currentLatLng.latitude == 0 && _currentLatLng.longitude == 0) {
              updateMapLocation(snapshot.data!);
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: currentZoomLevel,

                //could use later
                //   myLocationEnabled: true, // Show the user's current location on the map
                // myLocationButtonEnabled: true, // Enable the "My Location" button
                // initialCameraPosition: CameraPosition(
                // target: _currentLatLng,
                // zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("current"),
                  position: _currentLatLng,
                  draggable: true, // Make the marker draggable
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
            );
          } else {
            return const Center(child: Text("Loading..."));
          }
        },
      ),
    );
  }
}
