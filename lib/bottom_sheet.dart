import 'package:flutter/material.dart';
import 'package:safety_application/review_box.dart';

class ReviewSheet extends StatefulWidget {
  List<Map<String, dynamic>> reviews;
  double safetyScore;
  ReviewSheet({super.key, required this.reviews, required this.safetyScore});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  int _selectedTabIndex = 0; // 0 for Admin Reviews, 1 for User Reviews
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  final List<double> snapPositions = [
    0.075,
    0.75
  ]; // Only two states: Closed & Fully Open

  final List<bool> _expandedStates = List.generate(10, (_) => false);  // List of expanded states for each review

  void _toggleExpansion(int index) {
    setState(() {
      _expandedStates[index] = !_expandedStates[index];
    });
  }

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
            padding: const EdgeInsets.only(left: 22, right: 22, top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 100,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // PlaceName (change to current place)
                  Container(
                    padding: EdgeInsets.only(left: 15),
                    child: const Text(
                      "Kelambakkam",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Change the number to match safety
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 15),
                        child:
                          const Text(
                            "Safety Rating: ",
                            style: TextStyle(fontSize: 14),
                          ),
                      ),
                      const Text(
                        "6 (moderate)", // change this to >5 (unsafe), or <8 (safe), with red and green
                        style: TextStyle(fontSize: 14, color: Colors.orange),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Placeholder count
                      itemBuilder: (context, index) {
                        return Container(
                          width: 210,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey,
                          )
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.reviews.length,
                        itemBuilder: (context, index) {
                          // Safety check to avoid out-of-bounds errors
                          if (index >= _expandedStates.length) {
                            return const SizedBox.shrink(); // Skip invalid indices
                          }
                          final review = widget.reviews[index];
                          return ReviewTile(
                            index: index,
                            isExpanded: _expandedStates[index],
                            onTap: () => _toggleExpansion,
                            reviewData: review,
                          );
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
