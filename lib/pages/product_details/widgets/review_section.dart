import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewSection extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const ReviewSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Reviews",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (reviews.isEmpty)
            const Text(
              "No reviews yet.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else
            ...reviews.map((review) {
              final String reviewer = review['reviewer'] ?? 'Anonymous';
              final int rating = review['rating'] ?? 0;
              final String comment = review['comment'] ?? '';
              final String? mediaPath = review['media_path'];
              final DateTime date =
                  DateTime.tryParse(review['timestamp'] ?? '') ??
                  DateTime.now();
              final formattedDate = DateFormat.yMMMd().format(date);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 241, 239, 239),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reviewer name and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              reviewer,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Rating stars
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(height: 6),

                        // Comment
                        if (comment.isNotEmpty) Text(comment),

                        const SizedBox(height: 8),

                        if (mediaPath != null && mediaPath.isNotEmpty)
                          FutureBuilder<bool>(
                            future: File(mediaPath).exists(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(mediaPath),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
