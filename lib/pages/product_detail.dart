import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:second_project/widget/support_widget.dart';
import 'package:second_project/pages/checkout.dart';
import 'package:second_project/pages/cart.dart';

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  List<Map<String, dynamic>> recommended = [];
  List<Map<String, dynamic>> reviews = [];

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

  Future<void> submitReview(int rating, String reviewText) async {
    if (reviewText.trim().isEmpty) return;
    await DBHelper.instance.insertReview(
      widget.product['id'],
      rating,
      reviewText.trim(),
    );

    fetchReviews();
  }

  Future<void> addToCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartJson = prefs.getString('cart_products');
    List<Map<String, dynamic>> cartItems = [];

    if (cartJson != null) {
      List<dynamic> decoded = jsonDecode(cartJson);
      cartItems = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    bool exists = cartItems.any(
      (item) =>
          (item['product_id'] != null &&
              item['product_id'] == widget.product['product_id']) ||
          (item['product_name'] == widget.product['product_name'] &&
              item['product_price'] == widget.product['product_price'] &&
              item['category'] == widget.product['category']),
    );

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

  Widget buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Review",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          const Text(
            "No reviews yet.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ...reviews.map(
            (review) => ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text("⭐ ${review['rating']}"),
              subtitle: Text(review['review_text']),
            ),
          ),
      ],
    );
  }

  Widget buildRecommendations() {
    if (recommended.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text(
          "Recommended for You",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommended.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final p = recommended[index];
              final imageWidget =
                  p['image_path'] != null && File(p['image_path']).existsSync()
                      ? Image.file(File(p['image_path']), fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 50);

              return GestureDetector(
                onTap:
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetail(product: p),
                      ),
                    ),
                child: Container(
                  width: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: SizedBox(
                          height: 90,
                          width: double.infinity,
                          child: imageWidget,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          p['product_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Nrs. ${p['product_price']}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child:
                      widget.product['image_path'] != null &&
                              File(widget.product['image_path']).existsSync()
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(widget.product['image_path']),
                              height: 320,
                              width: 400,
                              fit: BoxFit.cover,
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
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
                        color: Colors.black,
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
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  topLeft: Radius.circular(30.0),
                ),
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
                        "Nrs. ${widget.product['product_price']?.toString() ?? '0'}",
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
                      color: Colors.black,
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
                  buildReviewSection(),
                  buildRecommendations(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}