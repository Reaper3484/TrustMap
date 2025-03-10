import 'package:flutter/material.dart';

class ReviewTile extends StatefulWidget {
  final int index;
  final Map<String, dynamic> reviewData;
  final bool isAdmin;

  const ReviewTile({
    super.key,
    required this.index,
    required this.reviewData,
    required this.isAdmin,
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
        child: widget.isAdmin ? _buildAdminReview() : _buildUserReview(),
      ),
    );
  }

  // Admin Review UI
  Widget _buildAdminReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Admin Review",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 8),
        _buildAdminDetail("User ID", widget.reviewData['userId'].toString()),
        _buildAdminDetail("Title", widget.reviewData['title'].toString()),
        _buildAdminDetail("Body", widget.reviewData['body'].toString()),
        _buildAdminDetail("Rating", widget.reviewData['rating'].toString()),
        _buildAdminDetail("Location", "${widget.reviewData['latitude']}, ${widget.reviewData['longitude']} (${widget.reviewData['location']})"),
      ],
    );
  }

  // User Review UI
  Widget _buildUserReview() {
    double lightingRating = (widget.reviewData['lighting'] ?? 0).toDouble();
    double securityRating = (widget.reviewData['security'] ?? 0).toDouble();
    double accessibilityRating = (widget.reviewData['accessibility'] ?? 0).toDouble();
    double crowdsRating = (widget.reviewData['crowdDensity'] ?? 0).toDouble();
    String reviewText = widget.reviewData['comment']?.toString() ?? "No comment available";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 25, backgroundColor: Colors.grey[300]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User ${widget.index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${(widget.index + 1) * 2} reviews",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text(
                  "4", // Placeholder rating
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
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
        Text(
          isExpanded || reviewText.length <= 50 ? reviewText : "${reviewText.substring(0, 50)}...",
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRatingColumn(String label, double rating) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.black),
            const SizedBox(width: 4),
            Text("$rating", style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}