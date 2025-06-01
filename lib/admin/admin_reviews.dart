import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final reviews = await DBHelper.instance.getAllReviews();
      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<void> _deleteReview(int id) async {
    try {
      await DBHelper.instance.deleteReview(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Review deleted")));
      _fetchReviews();
    } catch (e) {
      print('Error deleting review: $e');
    }
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review by: ${review['reviewer'] ?? 'Anonymous'}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text("Product ID: ${review['product_id']}"),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text("Rating: "),
                const Icon(Icons.star, color: Colors.amber, size: 18),
                Text('${review['rating']}'),
              ],
            ),
            const SizedBox(height: 8),
            Text("Comment: ${review['comment']}"),
            const SizedBox(height: 8),
            if (review['media_path'] != null &&
                review['media_path'].toString().isNotEmpty)
              Text("📎 Media: ${review['media_path']}"),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimestamp(review['timestamp']),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(review['id']);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete Review"),
            content: const Text("Are you sure you want to delete this review?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteReview(id);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return "No timestamp";
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Reviews"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      ),
      body:
          _reviews.isEmpty
              ? const Center(child: Text("No reviews available."))
              : ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(_reviews[index]);
                },
              ),
    );
  }
}
