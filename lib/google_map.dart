import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safety_application/bottom_sheet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safety_application/hamburger.dart';
import 'package:safety_application/config.dart';
import 'package:flutter/services.dart';

class GoogleMapFlutter extends StatefulWidget {
  final String token;
  const GoogleMapFlutter({super.key, required this.token});

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
  TextEditingController commentController = TextEditingController();

  // User marker
  Marker? _droppedPinMarker;
  String _droppedPinAddress = "";
  bool _isAddressLoading = false;


  final String _apiKey = dotenv.env['MAPS_API_KEY'] ?? "";

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
    print("API Key loaded: ${_apiKey.isEmpty ? 'No' : 'Yes'}"); // Debug print
    _initializeLocationTracking();
    _loadMarkersData().then((data) {
      _addMarkersAndCircles(
          data); // Add markers and circles after data is fetched
    });
  }

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  List<Map<String, dynamic>> _reviews = [];
  double currentSafetyScore = 0;

  // Fetch markers and circles from JSON data
  Future<List<Map<String, dynamic>>> _loadMarkersData() async {
    // Load the JSON file from assets
    String jsonString = await rootBundle.loadString('assets/markers.json');

    // Decode the JSON string
    final List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((data) => data as Map<String, dynamic>).toList();
  }

  void _addMarkersAndCircles(List<Map<String, dynamic>> data) {
    Set<Marker> markers = {};
    Set<Circle> circles = {};

    for (var item in data) {
      final position = LatLng(item['latitude'], item['longitude']);
      final marker = Marker(
        markerId: MarkerId(item['title']),
        position: position,
        infoWindow: InfoWindow(title: item['title']),
      );
      final circle = Circle(
        circleId: CircleId(item['title']),
        center: position,
        radius: item['radius'].toDouble(),
        fillColor: const Color.fromARGB(136, 255, 132, 132)
            .withOpacity(0.2), // Translucent color
        strokeWidth: 1,
        strokeColor: const Color.fromARGB(255, 250, 20, 20),
      );
      markers.add(marker);
      circles.add(circle);
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  // Add function to handle map long press
  void _onMapLongPress(LatLng position) async {
    setState(() {
      _isAddressLoading = true;
      // Create a new marker for the dropped pin
      _droppedPinMarker = Marker(
        markerId: const MarkerId('dropped_pin'),
        position: position,
        infoWindow: InfoWindow(title: 'Loading...'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      
      // Update the markers set to include the dropped pin
      _markers = {
        ..._markers,
        _droppedPinMarker!,
      };
    });
    
    // Get the address for the dropped pin
    await _getAddressFromLatLng(position);
  }

  // Function to get address from coordinates using reverse geocoding
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_apiKey'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // Get the formatted address from the first result
          final formattedAddress = data['results'][0]['formatted_address'];
          
          // Extract the locality or neighborhood from the address components
          String placeName = formattedAddress;
          for (var component in data['results'][0]['address_components']) {
            final types = component['types'] as List;
            if (types.contains('locality') || 
                types.contains('neighborhood') || 
                types.contains('sublocality_level_1')) {
              placeName = component['long_name'];
              break;
            }
          }
          
          setState(() {
            _isAddressLoading = false;
            _droppedPinAddress = placeName;
            
            // Update the marker with the address
            _droppedPinMarker = Marker(
              markerId: const MarkerId('dropped_pin'),
              position: position,
              infoWindow: InfoWindow(
                title: placeName,
                snippet: formattedAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            );
            
            // Update the markers set
            _markers = {
              ..._markers,
              _droppedPinMarker!,
            };
          });
          
          // Show a snackbar with the address
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location: $placeName'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _isAddressLoading = false;
          _droppedPinAddress = 'Unable to get address';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _isAddressLoading = false;
        _droppedPinAddress = 'Error getting address';
      });
    }
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
    if (_apiKey.isEmpty) {
      print("Error: API key is empty");
      return;
    }

    try {
      final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey");
      print("Calling API: $url"); // Debug URL

      final response = await http.get(url);
      print("API Response code: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _predictions = data['predictions'] ?? [];
          print("Predictions count: ${_predictions.length}");
        });
      } else {
        print("API error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Exception in _fetchPlacePredictions: $e");
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

  // Function to submit the review
  void _submitReview() async {
    if (_ratings.containsValue(0) || commentController.text.isEmpty) {
      // If any rating is missing or no comment is provided
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields before submitting!")),
      );
      return;
    }
    var reviewData = {
      "userId":
          "${widget.token}",
      "lighting": _ratings["Lighting"],
      "crowdDensity": _ratings["Crowded"],
      "security": _ratings["Security"],
      "accessibility": _ratings["Accessibility"],
      "comment": commentController.text,
      "latitude": _currentLocation!.latitude,
      "longitude": _currentLocation!.longitude,
    };

    print("Review JSON: ${jsonEncode(reviewData)}");

    _fetchReviews();

    try {
      var response = await http.post(
        Uri.parse(review), // Replace with your API URL
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode(reviewData),
      );

      var jsonResponse = jsonDecode(response.body);
      print("Login API Response: $jsonResponse"); // Debugging

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Review submitted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit review. Try again!")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error. Please check your connection.")),
      );
    }
  }

  Future<void> _fetchReviews() async {
    if (!mounted) return;

    try {
      print('$reviews?latitude=${_currentLocation!.latitude}&longitude=${_currentLocation!.longitude}');
      final response = await http.get(Uri.parse(
          '$reviews?latitude=${_currentLocation!.latitude}&longitude=${_currentLocation!.longitude}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _reviews = List<Map<String, dynamic>>.from(data['data']);
          currentSafetyScore = data['safetyScore'];
          print(_reviews);
        });
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
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
            markers: _markers,
            circles: _circles,
            onCameraMove: (_) {
              setState(() {
                _isUserNavigating =
                    true; // Disable auto-panning when user moves the map
              });
            },
            onLongPress: _onMapLongPress,
          ),

          if (_isAddressLoading)
            const Center(
              child: CircularProgressIndicator(),
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
          ReviewSheet(reviews: _reviews, safetyScore: currentSafetyScore),
          HamburgerMenu(),
          // Refresh Button (Below Hamburger Menu)
          Positioned(
            top: 120, // Adjust as needed to position below the hamburger menu
            right: 20,
            child: FloatingActionButton(
              onPressed:
                  _fetchReviews, // Calls the getReviews function on press
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.refresh, color: Colors.black),
            ),
          ),

          // SOS Button
          Positioned(
            top: 190, // Adjust as needed to position below the hamburger menu
            right: 19,
            child: SizedBox(
              width: 57, // Set width of the button
              height: 57, // Set height of the button
              child: FloatingActionButton(
                onPressed:
                    _fetchReviews, // Calls the getReviews function on press
                backgroundColor: const Color.fromARGB(255, 247, 10, 10),
                shape: const CircleBorder(),
                child: const Center(
                  child: Text(
                    'SOS', // Text inside the button
                    style: TextStyle(
                      fontSize: 20, // Large font size for the text
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 50, // Adjust for vertical position
            right: 20, // Adjust for horizontal position
            child: FloatingActionButton(
              onPressed: () {
                if (_isReviewVisible) {
                  _submitReview();
                }
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
            controller: commentController,
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
