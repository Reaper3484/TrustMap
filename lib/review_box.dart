import 'package:flutter/material.dart';

class ReviewTile extends StatelessWidget {
  final int index;
  final bool isExpanded;
  final Function() onTap;
  final Map<String, dynamic> reviewData;

  const ReviewTile({
    super.key,
    required this.index,
    required this.isExpanded,
    required this.onTap,
    required this.reviewData
  });

  @override
  Widget build(BuildContext context) {
    // Sample rating for illustration (1-5 stars)
    double lightingRating = (reviewData['lighting'] ?? 0).toDouble();
    double securityRating = (reviewData['security'] ?? 0).toDouble();
    double accessibilityRating = (reviewData['accessibility'] ?? 0).toDouble();
    double crowdsRating = (reviewData['crowdDensity'] ?? 0).toDouble();
    String reviewText = reviewData['comment']?.toString() ?? "No comment available";
    String userId = reviewData['userId']?.toString() ?? "Unknown User";

    return GestureDetector(
      onTap: onTap,  // Trigger the expansion when the box is tapped
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),  // Animation duration
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        height: isExpanded ? 250 : 160,  // Animate height of the container
        child: SingleChildScrollView(  // Wrap the content inside a scroll view
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Profile Picture, Username, and Rating
              Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color.fromARGB(255, 205, 211, 214),
                  ),
                  const SizedBox(width: 12),

                  // Username & Number of Reviews
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User ${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${(index + 1) * 2} reviews", // Placeholder for number of reviews left
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Safety Rating (Big Black Star and Rating Value)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.black,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "4",  // The rating value
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Individual Ratings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRatingColumn("Lighting", lightingRating),
                  _buildRatingColumn("Security", securityRating),
                  _buildRatingColumn("Accessibility", accessibilityRating),
                  _buildRatingColumn("Crowds", crowdsRating),
                ],
              ),

              const SizedBox(height: 8),

              // Expandable Review Text
              Text(
                isExpanded || reviewText.length <= 50 
                  ? reviewText 
                  : "${reviewText.substring(0, 50)}...",
                style: const TextStyle(fontSize: 14),
              ),            ],
          ),
        ),
      ),
    );
  }

  // Helper function to display individual ratings
  Widget _buildRatingColumn(String label, double rating) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            const SizedBox(width: 4),
            Text(
              "$rating",  // Individual rating
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
