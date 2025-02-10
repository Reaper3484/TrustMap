import 'package:flutter/material.dart';

class ReviewTile extends StatelessWidget {
  final int index;

  const ReviewTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Sample rating for illustration (1-5 stars)
    double rating = (index % 5) + 1.0;  

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
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

              // Safety Rating (Stars)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (starIndex) {
                  return Icon(
                    starIndex < rating ? Icons.star : Icons.star_border,
                    color: Colors.blue,
                    size: 18,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Review Text
          const Text(
            "This is a sample review about this location. It's a great place with lots of things to explore.",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
