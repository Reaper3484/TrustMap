import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safety_application/bottom_sheet.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  late GoogleMapController _mapController;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  // Continuously track user location
  void _initializeLocationTracking() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Ensure location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    // Ensure app has permission to access location
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get real-time location updates
    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng newLocation = LatLng(locationData.latitude!, locationData.longitude!);

        // Move map camera to new location smoothly
        _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 18),
            zoomControlsEnabled: false,
            myLocationEnabled: true, // Enables Google Maps blue dot
            myLocationButtonEnabled: true, // Disables default location button
            onMapCreated: (controller) => _mapController = controller,
          ),

          // Draggable Bottom Sheet (Overlay)
          const ReviewSheet(),
        ],
      ),
    );
  }
}
