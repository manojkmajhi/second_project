import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:second_project/widget/support_widget.dart';
import 'package:second_project/pages/checkout.dart';
import 'package:second_project/pages/cart.dart';

class ProductDetail extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetail({super.key, required this.product});

  Future<void> addToCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartJson = prefs.getString('cart_products');
    List<Map<String, dynamic>> cartItems = [];

    if (cartJson != null) {
      List<dynamic> decoded = jsonDecode(cartJson);
      cartItems = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Check if the product is already in the cart
    bool exists = cartItems.any(
      (item) =>
          (item['product_id'] != null &&
              item['product_id'] == product['product_id']) ||
          (item['product_name'] == product['product_name'] &&
              item['product_price'] == product['product_price'] &&
              item['category'] == product['category']),
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

    final newProduct = Map<String, dynamic>.from(product);
    newProduct['quantity'] = 1;
    cartItems.add(newProduct);

    await prefs.setString('cart_products', jsonEncode(cartItems));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Added to cart")));
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
                      product['image_path'] != null &&
                              File(product['image_path']).existsSync()
                          ? Image.file(
                            File(product['image_path']),
                            height: 400,
                            width: 400,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            "assets/logo/ToolKit_logo.png",
                            height: 400,
                            width: 400,
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
                          product['product_name'] ?? 'No name',
                          style: AppWidget.boldTextFieldStyle(),
                        ),
                      ),
                      Text(
                        "Nrs. ${product['product_price']?.toString() ?? '0'}",
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
                    "Category: ${product['category'] ?? 'N/A'}",
                    style: AppWidget.semiboldTextFieldStyle(),
                  ),
                  const SizedBox(height: 10),
                  Text("Details:", style: AppWidget.semiboldTextFieldStyle()),
                  const SizedBox(height: 5),
                  Text(
                    product['details'] ?? 'No details available.',
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Checkout(),
                                settings: RouteSettings(arguments: [product]),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
