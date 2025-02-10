import 'package:flutter/material.dart';
import 'package:safety_application/review_box.dart';

class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  final List<double> snapPositions = [
    0.075,
    0.75
  ]; // Only two states: Closed & Fully Open

  void _onSheetDragEnd() {
    double currentSize = _controller.size;

    // Find closest snap position
    double closestSize = snapPositions.reduce(
        (a, b) => (a - currentSize).abs() < (b - currentSize).abs() ? a : b);

    // Animate to the closest snap position
    _controller.animateTo(
      closestSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.075,
      minChildSize: 0.075,
      maxChildSize: 0.75,
      snap: true, // Enables snapping
      builder: (context, scrollController) {
        return GestureDetector(
          onVerticalDragEnd: (_) => _onSheetDragEnd(), // Snap on release
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Unsafe & Safe Zone Indicators
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                                255, 255, 201, 201), // White background
                            border: Border.all(
                                color: Colors.red, width: 2), // Thin red border
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Unsafe Zone",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold, // Bold text
                                ),
                              ),
                              const SizedBox(height: 5), // Spacing
                              const Text(
                                "Safety Rating: 2.1/5", // Example rating (Replace dynamically)
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                                255, 201, 203, 255), // White background
                            border: Border.all(
                                color: const Color.fromARGB(255, 54, 124, 244),
                                width: 2), // Thin red border
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Safe Zone",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 54, 82, 244),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold, // Bold text
                                ),
                              ),
                              const SizedBox(height: 5), // Spacing
                              const Text(
                                "Distance: 200m", // Example rating (Replace dynamically)
                                style: TextStyle(
                                  color: Color.fromARGB(255, 54, 82, 244),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Photo Gallery (Horizontal Scroll)
                  const Text(
                    "Photos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Placeholder count
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 211, 209, 209)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reviews (Vertical Scroll)
                  const Text(
                    "Reviews",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent scroll conflict
                    itemCount: 5, // Placeholder count
                    itemBuilder: (context, index) {
                      return ReviewTile(index: index);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
