import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/pages/product_details/widgets/recommendation_section.dart';
import 'package:second_project/pages/product_details/widgets/review_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:second_project/database/data/local/db_helper.dart';
import 'package:second_project/widget/support_widget.dart';
import 'package:second_project/pages/checkout.dart';
import 'package:second_project/pages/cart/cart.dart';

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  List<Map<String, dynamic>> recommended = [];
  List<Map<String, dynamic>> reviews = [];

  int userRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    incrementSearchCount();
    fetchRecommendations();
    fetchReviews();
  }

  Future<void> incrementSearchCount() async {
    if (widget.product['product_name'] != null) {
      await DBHelper.instance.incrementSearchCount(
        widget.product['product_name'],
      );
    }
  }

  Future<void> fetchRecommendations() async {
    final product = widget.product;
    List<Map<String, dynamic>> recs = await DBHelper.instance
        .getRecommendedProductsSimple(
          product['category'] ?? '',
          product['id'],
          productName: product['product_name'],
          details: product['details'],
        );
    setState(() => recommended = recs);
  }

  Future<void> fetchReviews() async {
    List<Map<String, dynamic>> data = await DBHelper.instance
        .getReviewsByProductId(widget.product['id']);
    setState(() => reviews = data);
  }

  Future<void> addToCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartJson = prefs.getString('cart_products');
    List<Map<String, dynamic>> cartItems = [];

    if (cartJson != null) {
      cartItems =
          (jsonDecode(cartJson) as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
    }

    final currentId = widget.product['product_id'] ?? widget.product['id'];

    bool exists = cartItems.any((item) {
      final itemId = item['product_id'] ?? item['id'];
      return itemId == currentId;
    });

    if (exists) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Already in Cart"),
              content: const Text("This product is already in your cart."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                  child: const Text("Go to Cart"),
                ),
              ],
            ),
      );
      return;
    }

    final newProduct = Map<String, dynamic>.from(widget.product);
    newProduct['quantity'] = 1;
    cartItems.add(newProduct);
    await prefs.setString('cart_products', jsonEncode(cartItems));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Added to cart")));
  }

  Future<void> submitReview() async {
    final productId = widget.product['id'];
    final comment = _reviewController.text.trim();

    if (userRating == 0 && comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating or comment.")),
      );
      return;
    }

    await DBHelper.instance.insertReview(
      productId: productId,
      rating: userRating,
      reviewText: comment,
    );

    _reviewController.clear();
    userRating = 0;

    fetchReviews();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.product['image_path'];
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:
                        hasImage
                            ? Image.file(
                              File(imagePath),
                              height: 320,
                              width: 400,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              "assets/logo/ToolKit_logo.png",
                              height: 350,
                              width: 400,
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 30.0,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['product_name'] ?? 'No name',
                          style: AppWidget.boldTextFieldStyle(),
                        ),
                      ),
                      Text(
                        "Nrs. ${widget.product['product_price']}",
                        style: const TextStyle(
                          color: Color.fromARGB(135, 213, 91, 91),
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Category: ${widget.product['category'] ?? 'N/A'}",
                    style: AppWidget.semiboldTextFieldStyle(),
                  ),
                  const SizedBox(height: 10),
                  Text("Details:", style: AppWidget.semiboldTextFieldStyle()),
                  const SizedBox(height: 5),
                  Text(
                    widget.product['details'] ?? 'No details available.',
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Checkout(),
                                settings: RouteSettings(
                                  arguments: [widget.product],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: const Center(
                              child: Text(
                                "Buy Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => addToCart(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: const Center(
                              child: Text(
                                "Add to Cart",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ReviewSection(
                    reviews: reviews,
                    
                  ),
                  const SizedBox(height: 30),
                  RecommendationSection(recommended: recommended),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
