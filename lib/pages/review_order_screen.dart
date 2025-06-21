import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:second_project/database/data/local/db_helper.dart';

class ReviewOrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const ReviewOrderScreen({super.key, required this.products});

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  final Map<int, int> _ratings = {};
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, List<String>> _mediaPaths = {};
  final ImagePicker _picker = ImagePicker();
  final Set<int> _reviewedProducts =
      {}; // Track which products have been reviewed

  @override
  void initState() {
    super.initState();
    for (var product in widget.products) {
      final productId = product['id'] ?? product['product_id'];
      if (productId != null) {
        _controllers[productId] = TextEditingController();
        // Check if this product already has a review
        _checkExistingReview(productId);
      }
    }
  }

  Future<void> _checkExistingReview(int productId) async {
    final existingReviews = await DBHelper.instance.getReviewsForProduct(
      productId,
    );
    if (existingReviews.isNotEmpty) {
      setState(() {
        _reviewedProducts.add(productId);
        // Optionally, you could load the existing review data here
      });
    }
  }

  Future<void> _pickMedia(int productId) async {
    if (_reviewedProducts.contains(productId)) return;

    await showModalBottomSheet(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Pick Images from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final images = await _picker.pickMultiImage();
                    if (images.isNotEmpty) {
                      setState(() {
                        _mediaPaths[productId] = [
                          ...?_mediaPaths[productId],
                          ...images.map((img) => img.path),
                        ];
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Pick Video from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final video = await _picker.pickVideo(
                      source: ImageSource.gallery,
                    );
                    if (video != null) {
                      setState(() {
                        _mediaPaths[productId] = [
                          ...?_mediaPaths[productId],
                          video.path,
                        ];
                      });
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _submitReviews() async {
    bool submitted = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      for (var product in widget.products) {
        final productId = product['id'] ?? product['product_id'];
        if (productId == null || _reviewedProducts.contains(productId))
          continue;

        final rating = _ratings[productId] ?? 0;
        final comment = _controllers[productId]?.text.trim() ?? '';
        final mediaList = _mediaPaths[productId] ?? [];

        if (rating > 0 || comment.isNotEmpty || mediaList.isNotEmpty) {
          if (mediaList.isEmpty) {
            await DBHelper.instance.insertReview(
              productId: productId,
              rating: rating,
              reviewText: comment,
              mediaPath: '',
            );
          } else {
            for (final path in mediaList) {
              await DBHelper.instance.insertReview(
                productId: productId,
                rating: rating,
                reviewText: comment,
                mediaPath: path,
              );
            }
          }
          setState(() {
            _reviewedProducts.add(productId);
          });
          submitted = true;
        }
      }

      if (!mounted) return;
      Navigator.pop(context);

      if (submitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reviews submitted successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please add at least one review for unreviewed products.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting reviews: $e')));
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildProductReviewCard(Map<String, dynamic> product) {
    final productId = product['id'] ?? product['product_id'];
    final productName = product['product_name'] ?? 'Unnamed Product';
    final imagePath = product['image_path'] ?? product['image'] ?? '';
    if (productId == null) return const SizedBox();

    final isReviewed = _reviewedProducts.contains(productId);
    final mediaList = _mediaPaths[productId] ?? [];

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image:
                          imagePath.isNotEmpty
                              ? FileImage(File(imagePath))
                              : const AssetImage('assets/images/default.png')
                                  as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isReviewed)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
              ],
            ),
            if (!isReviewed) ...[
              const SizedBox(height: 10),
              const Text(
                'Your Rating',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (star) {
                  final rating = _ratings[productId] ?? 0;
                  return IconButton(
                    icon: Icon(
                      star < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _ratings[productId] = star + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controllers[productId],
                decoration: InputDecoration(
                  labelText: 'Write a review (optional)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () => _pickMedia(productId),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              if (mediaList.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      mediaList.map((path) {
                        final isVideo =
                            path.endsWith('.mp4') ||
                            path.endsWith('.mov') ||
                            path.endsWith('.avi');
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!isVideo) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => Dialog(
                                          child: Image.file(File(path)),
                                        ),
                                  );
                                }
                              },
                              child:
                                  isVideo
                                      ? Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.black12,
                                        child: const Center(
                                          child: Icon(Icons.videocam, size: 40),
                                        ),
                                      )
                                      : Image.file(
                                        File(path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _mediaPaths[productId]?.remove(path);
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'You have already reviewed this product',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Products'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body:
          widget.products.isEmpty
              ? const Center(child: Text('No products to review.'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.products.length,
                      itemBuilder: (context, index) {
                        return _buildProductReviewCard(widget.products[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(width: double.infinity),
                  ),
                ],
              ),
    );
  }
}
