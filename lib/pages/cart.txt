import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:second_project/pages/checkout.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartProducts = [];
  List<bool> selectedItems = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserAndCart();
  }

  Future<void> loadUserAndCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    debugPrint("🔐 Loaded userId: $userId");

    if (userId != null) {
      String? cartJson = prefs.getString('cart_products_$userId');
      debugPrint("📦 Loaded cart for user $userId: $cartJson");

      if (cartJson != null && cartJson.isNotEmpty) {
        List<dynamic> decoded = jsonDecode(cartJson);
        setState(() {
          cartProducts =
              decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          selectedItems = List<bool>.filled(cartProducts.length, false);
        });
      } else {
        debugPrint("🧺 Cart is empty.");
      }
    } else {
      debugPrint("❌ No userId found. Cart not loaded.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to view your cart.")),
      );
    }
  }

  Future<void> saveCart() async {
    if (userId == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (cartProducts.isEmpty) {
      await prefs.remove('cart_products_$userId');
    } else {
      await prefs.setString('cart_products_$userId', jsonEncode(cartProducts));
    }
  }

  void removeProduct(int index) async {
    if (index < cartProducts.length) {
      setState(() {
        cartProducts.removeAt(index);
        selectedItems = List<bool>.filled(cartProducts.length, false);
      });
      await saveCart();
    }
  }

  void updateQuantity(int index, int change) async {
    if (index < cartProducts.length) {
      int currentQty = cartProducts[index]['quantity'] ?? 1;
      int newQty = currentQty + change;
      if (newQty > 0) {
        setState(() {
          cartProducts[index]['quantity'] = newQty;
        });
        await saveCart();
      }
    }
  }

  double getTotalPrice() {
    double total = 0.0;
    for (int i = 0; i < cartProducts.length; i++) {
      if (i < selectedItems.length && selectedItems[i]) {
        double price =
            double.tryParse(cartProducts[i]['product_price'].toString()) ?? 0.0;
        int qty = cartProducts[i]['quantity'] ?? 1;
        total += price * qty;
      }
    }
    return total;
  }

  void toggleSelection(int index) {
    if (index < selectedItems.length) {
      setState(() {
        selectedItems[index] = !selectedItems[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body:
          cartProducts.isEmpty
              ? const Center(
                child: Text(
                  "Your cart is empty!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProducts.length,
                      itemBuilder: (context, index) {
                        final product = cartProducts[index];
                        double price =
                            double.tryParse(
                              product['product_price'].toString(),
                            ) ??
                            0.0;
                        int quantity = product['quantity'] ?? 1;

                        bool imageExists = false;
                        if (product['image_path'] != null) {
                          try {
                            imageExists =
                                File(product['image_path']).existsSync();
                          } catch (e) {
                            imageExists = false;
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value:
                                    selectedItems.length > index &&
                                    selectedItems[index],
                                onChanged: (_) => toggleSelection(index),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    imageExists
                                        ? Image.file(
                                          File(product['image_path']),
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        )
                                        : Image.asset(
                                          "assets/logo/ToolKit_logo.png",
                                          height: 60,
                                          width: 60,
                                        ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['product_name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Nrs.${price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed:
                                              () => updateQuantity(index, -1),
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                        ),
                                        Text('$quantity'),
                                        IconButton(
                                          onPressed:
                                              () => updateQuantity(index, 1),
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Nrs.${(price * quantity).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => removeProduct(index),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Nrs.${getTotalPrice().toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final selectedProducts = [
                                for (int i = 0; i < cartProducts.length; i++)
                                  if (i < selectedItems.length &&
                                      selectedItems[i])
                                    cartProducts[i],
                              ];

                              if (selectedProducts.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please select at least one product.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Checkout(),
                                  settings: RouteSettings(
                                    arguments: selectedProducts,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Proceed to Checkout",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
