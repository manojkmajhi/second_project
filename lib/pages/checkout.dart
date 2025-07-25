import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/database/data/local/db_helper.dart';
import 'package:second_project/pages/add_address_info.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late List<Map<String, dynamic>> products;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List) {
      products = args.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      products = [];
    }
  }

  void updateQuantity(int index, int change) {
    setState(() {
      int newQty = (products[index]['quantity'] ?? 1) + change;
      if (newQty >= 1) {
        products[index]['quantity'] = newQty;
      }
    });
  }

  double getTotalPrice() {
    return products.fold(0, (sum, product) {
      double price =
          double.tryParse(product['product_price'].toString()) ?? 0.0;
      int qty = product['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }

  Future<bool> _validateQuantities() async {
    final db = await DBHelper.instance.getDB();

    for (var product in products) {
      final productId = product['product_id'] ?? product['id'];
      final orderedQty = product['quantity'] ?? 1;

      final result = await db.query(
        DBHelper.productTableName,
        where: 'id = ?',
        whereArgs: [productId],
      );

      if (result.isNotEmpty) {
        final availableQty = result.first['product_quantity'] as int;
        if (orderedQty > availableQty) {
          _showStockWarning(product['product_name'], availableQty);
          return false;
        }
      } else {
        _showProductNotFound(product['product_name']);
        return false;
      }
    }
    return true;
  }

  void _showStockWarning(String productName, int availableQty) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Insufficient Stock"),
            content: Text(
              "Not enough stock for $productName. Only $availableQty available.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showProductNotFound(String productName) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Product Not Available"),
            content: Text("$productName is no longer available."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to previous screen
                },
                child: const Text("Return to Home"),
              ),
            ],
          ),
    );
  }

  Future<void> _proceedToCheckout() async {
    setState(() => isLoading = true);
    final isValid = await _validateQuantities();
    setState(() => isLoading = false);

    if (isValid && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddAddressInfo(),
          settings: RouteSettings(arguments: products),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No products selected for checkout.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      final product = products[index];
                      double price =
                          double.tryParse(
                            product['product_price'].toString(),
                          ) ??
                          0.0;
                      int quantity = product['quantity'] ?? 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  product['image_path'] != null &&
                                          File(
                                            product['image_path'],
                                          ).existsSync()
                                      ? Image.file(
                                        File(product['image_path']),
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        "assets/logo/ToolKit.png",
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Nrs.${price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed:
                                            () => updateQuantity(index, -1),
                                      ),
                                      Text(
                                        quantity.toString(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed:
                                            () => updateQuantity(index, 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "Nrs.${(price * quantity).toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Nrs.${getTotalPrice().toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _proceedToCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Confirm Order",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
