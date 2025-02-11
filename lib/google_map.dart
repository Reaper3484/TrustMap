import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safety_application/bottom_sheet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safety_application/hamburger.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  late GoogleMapController _mapController;
  final Location _location = Location();
  bool _isReviewVisible = false; // Track if review form is open
  final TextEditingController _searchController = TextEditingController();

  bool _isUserNavigating =
      false; // Prevents auto-panning when manually navigating
  List<dynamic> _predictions = [];
  String? _selectedPlaceId;
  LatLng? _selectedLocation;
  LocationData? _currentLocation;

  final String _apiKey =
      "AIzaSyB5vsTeBTbw4amWNXb0DXPnx9PVxQwK6M8"; // Replace with actual API Key

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

    _location.getLocation().then((locationData) {
      setState(() {
        _currentLocation = locationData;
      });
      if (_currentLocation != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            15,
          ),
        );
      }
    });

    _location.onLocationChanged.listen((locationData) {
      if (!_isUserNavigating) {
        setState(() {
          _currentLocation = locationData;
        });
          _mapController.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(locationData.latitude!, locationData.longitude!),
            ),
          );
      }
    });
  }

  // Fetch place predictions
  Future<void> _fetchPlacePredictions(String input) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _predictions = data['predictions'] ?? [];
      });
    }
  }

  // Fetch place coordinates
  Future<void> _fetchPlaceCoordinates(String placeId) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      setState(() {
        _selectedLocation = LatLng(location['lat'], location['lng']);
        _isUserNavigating =
            true; // Disable auto-tracking when user selects a place
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation != null
                  ? LatLng(
                      _currentLocation!.latitude!, _currentLocation!.longitude!)
                  : LatLng(0, 0),
              zoom: 15,
            ),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (_) {
              setState(() {
                _isUserNavigating =
                    true; // Disable auto-panning when user moves the map
              });
            },
          ),
          // Search Bar
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _fetchPlacePredictions(value);
                      } else {
                        setState(() => _predictions = []);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Search a location...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (_selectedLocation != null) {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                  _selectedLocation!, 15),
                            );
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                // Predictions List
                if (_predictions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: _predictions
                          .map(
                            (prediction) => ListTile(
                              title: Text(prediction['description']),
                              onTap: () {
                                setState(() {
                                  _searchController.text =
                                      prediction['description'];
                                  _selectedPlaceId = prediction['place_id'];
                                  _predictions = [];
                                });

                                // Fetch coordinates and stop auto-tracking
                                _fetchPlaceCoordinates(_selectedPlaceId!);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Current Location Button (Above FAB)
          Positioned(
            bottom: 120, // Adjust to be above the FAB
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_currentLocation != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      15,
                    ),
                  );
                }
              },
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              shape: const CircleBorder(),
              child: const Icon(Icons.my_location,
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),

          // Draggable Bottom Sheet (Overlay)
          const ReviewSheet(),
          HamburgerMenu(),

          Positioned(
            bottom: 50,   // Adjust for vertical position
            right: 20,    // Adjust for horizontal position
            child: FloatingActionButton(
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
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isReviewVisible ? 20 : -300, // Moves in from the right
            bottom: 120, // Keeps it slightly above FAB
              child: _isReviewVisible ? _buildReviewForm() : Container(),
            ),
        ],
      ),


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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Write a Review",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isReviewVisible = false;
                });
              },
            ),
          ],
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
        Flexible(
          // Ensures text doesn't cause overflow
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
