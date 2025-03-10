import 'package:flutter/material.dart';
import 'package:safety_application/review_box.dart';

const largeBorderRadius = 28.0;
const mediumBorderRadius = 20.0;
const smallBorderRadius = 16.0;

class ReviewSheet extends StatefulWidget {
  List<Map<String, dynamic>> reviews;
  List<Map<String, dynamic>> adminReviews;
  double safetyScore;
  String location;
  ReviewSheet({super.key, required this.reviews, required this.adminReviews, required this.safetyScore, required this.location});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  int _selectedTabIndex = 0; // 0 for Admin Reviews, 1 for User Reviews
  final List<double> snapPositions = [
    0.075,
    0.75
  ]; // Only two states: Closed & Fully Open

  final List<bool> _expandedStates = List.generate(10, (_) => false);  // List of expanded states for each review

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

  Widget _buildTabBox() {
    return Container(
      margin: const EdgeInsets.only(top: 30, bottom: 30),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(mediumBorderRadius),
      ),
      child: Row(
        children: [
          // Admin Reviews Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(smallBorderRadius),
                ),
                child: Center(
                  child: Text(
                    "Admin Reports",
                    style: TextStyle(
                      color: _selectedTabIndex == 0 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // User Reviews Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(smallBorderRadius),
                ),
                child: Center(
                  child: Text(
                    "User Reports",
                    style: TextStyle(
                      color: _selectedTabIndex == 1 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.14,
      minChildSize: 0.14,
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
                      width: 100,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // PlaceName (change to current place)
                  Container(
                    padding: EdgeInsets.only(left: 15),
                    child:  Text(
                      widget.location,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Change the number to match safety
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 15),
                        child:
                          const Text(
                            "Safety Rating: ",
                            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                      ),
                      const Text(
                        "6 (moderate)", // change this to >5 (unsafe), or <8 (safe), with red and green
                        style: TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  _buildTabBox(),

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
                  Text(
                    _selectedTabIndex == 1 ? "User Reports" : "Admin Reports",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedTabIndex == 0 ? widget.adminReviews.length : widget.reviews.length,
                    itemBuilder: (context, index) {
                      final selectedReviews = _selectedTabIndex == 0 ? widget.adminReviews : widget.reviews;

                      // Safety check to avoid out-of-bounds errors
                      if (index >= selectedReviews.length) {
                        return const SizedBox.shrink(); // Skip invalid indices
                      }

                      final review = selectedReviews[index];
                      return ReviewTile(
                        index: index,
                        reviewData: review,
                        isAdmin: _selectedTabIndex == 0 ? true : false
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
