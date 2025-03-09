import 'package:flutter/material.dart';
import 'package:safety_application/review_box.dart';

const largeBorderRadius = 28.0;
var mediumBorderRadius = 20.0;
var smallBorderRadius = 16.0;

class ReviewSheet extends StatefulWidget {
  List<Map<String, dynamic>> reviews;
  double safetyScore;
  ReviewSheet({super.key, required this.reviews, required this.safetyScore});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  var mediumBorderRadius = 20.0;
  var smallBorderRadius = 16.0;

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

  // Tab box widget
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
                    "Admin Reviews",
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
                    "User Reviews",
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
                  const BorderRadius.vertical(top: Radius.circular(largeBorderRadius)),
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
                        borderRadius: BorderRadius.circular(smallBorderRadius),
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
                            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                      ),
                      const Text(
                        "6 (moderate)", // change this to >5 (unsafe), or <8 (safe), with red and green
                        style: TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // Add tab box here
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

                  
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.reviews
                      .where((review) => _selectedTabIndex == 0 
                        ? review['isAdmin'] == true 
                        : review['isAdmin'] != true)
                      .toList()
                      .length,
                    itemBuilder: (context, index) {
                      // Get filtered reviews based on selected tab
                      final filteredReviews = widget.reviews
                        .where((review) => _selectedTabIndex == 0 
                          ? review['isAdmin'] == true 
                          : review['isAdmin'] != true)
                        .toList();
                      
                      // Safety check to avoid out-of-bounds errors
                      if (index >= filteredReviews.length || index >= _expandedStates.length) {
                        return const SizedBox.shrink(); // Skip invalid indices
                      }
                      
                      final review = filteredReviews[index];
                      return ReviewCard(
                        isExpanded: _expandedStates[index],
                        onTap: () => _toggleExpansion(index),
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

// Custom ReviewCard widget
class ReviewCard extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;
  final Map<String, dynamic> reviewData;

  const ReviewCard({
    Key? key,
    required this.isExpanded,
    required this.onTap,
    required this.reviewData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    // If there's a profile image URL in the review data, use it
                    // backgroundImage: reviewData['profileImage'] != null
                    //     ? NetworkImage(reviewData['profileImage'])
                    //     : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // User info and review content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User name and verified badge if admin
                        Row(
                          children: [
                            Text(
                              reviewData['userName'] ?? 'Ananas C.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (reviewData['isAdmin'] == true) 
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        
                        // Report count
                        Text(
                          reviewData['reportCount']?.toString() ?? '69 reports',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Review title
                        Text(
                          reviewData['title'] ?? 'Kidnapping of a 4 year old',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        
                        // Review description (truncated if not expanded)
                        Text(
                          reviewData['description'] ?? 'A 4 year old boy went missing at this place.',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Date
                  Text(
                    reviewData['date'] ?? '12/06/2024',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              // Additional details when expanded
              if (isExpanded) ...[
                const SizedBox(height: 10),
                // Add more expanded content here if needed
              ],
            ],
          ),
        ),
      ),
    );
  }
}