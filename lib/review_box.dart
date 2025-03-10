import 'package:flutter/material.dart';

class ReviewTile extends StatefulWidget {
  final int index;
  final Map<String, dynamic> reviewData;

  const ReviewTile({
    super.key,
    required this.index,
    required this.reviewData,
  });

  @override
  _ReviewTileState createState() => _ReviewTileState();
}

class _ReviewTileState extends State<ReviewTile> {
  bool isExpanded = false;

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    double lightingRating = (widget.reviewData['lighting'] ?? 0).toDouble();
    double securityRating = (widget.reviewData['security'] ?? 0).toDouble();
    double accessibilityRating = (widget.reviewData['accessibility'] ?? 0).toDouble();
    double crowdsRating = (widget.reviewData['crowdDensity'] ?? 0).toDouble();
    String reviewText = widget.reviewData['comment']?.toString() ?? "No comment available";
    String status = widget.reviewData['status']?.toString() ?? "No status";

    return GestureDetector(
      onTap: toggleExpanded,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(minHeight: 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Profile Picture, Username, Rating
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color.fromARGB(255, 205, 211, 214),
                ),
                const SizedBox(width: 12),

                // Username & Review Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User ${widget.index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${(widget.index + 1) * 2} reviews",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating (with optional green tick for approved status)
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "4", // Placeholder rating
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (status == "approved") ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Ratings for different categories
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
            ),
          ],
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
            const Icon(
              Icons.star,
              size: 16,
              color: Colors.black,
            ),
            const SizedBox(width: 4),
            Text(
              "$rating",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}