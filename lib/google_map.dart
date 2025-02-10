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
  bool _isReviewVisible = false; // Track if review form is open

  // Store selected ratings (0-5) for each category
  final Map<String, int> _ratings = {
    "Lighting": 0,
    "Crowded": 0,
    "Security": 0,
    "Accessibility": 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  void _initializeLocationTracking() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng newLocation = LatLng(locationData.latitude!, locationData.longitude!);
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
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
          ),

          // Draggable Bottom Sheet (Overlay)
          const ReviewSheet(),

          // Floating Review Form (Slides in from the right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isReviewVisible ? 20 : -300, // Moves in from the right
            bottom: 110, // Keeps it slightly above FAB
            child: _isReviewVisible ? _buildReviewForm() : Container(),
          ),
        ],
      ),

      // Floating Action Button (Black Background, White Pencil)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isReviewVisible = !_isReviewVisible;
          });
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: Icon(
          _isReviewVisible ? Icons.arrow_forward : Icons.edit,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildReviewForm() {
    return Container(
      width: 320, // Reduced width to prevent overflow
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Write a Review",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            softWrap: false, 
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 15),

          // Rating categories with stars
          _buildRatingRow("Lighting"),
          const SizedBox(height: 15),
          _buildRatingRow("Crowded"),
          const SizedBox(height: 15),
          _buildRatingRow("Security"),
          const SizedBox(height: 15),
          _buildRatingRow("Accessibility"),
          const SizedBox(height: 15),

          // Comment Box
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Leave a comment...",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Row for each rating category
  Widget _buildRatingRow(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible( // Ensures text doesn't cause overflow
          child: Text(
            label, 
            style: const TextStyle(fontSize: 18, fontFamily: 'Rubik'), 
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min, // Prevents extra spacing
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _ratings[label] = index + 1; // Update rating
                });
              },
              child: Icon(
                Icons.star,
                size: 23, // Adjust size to prevent overflow
                color: index < _ratings[label]! ? Colors.yellow : Colors.black,
              ),
            );
          }),
        ),
      ],
    );
  }
}
