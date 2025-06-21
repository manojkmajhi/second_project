import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/admin/update_product.dart';
import 'package:second_project/database/data/local/db_helper.dart';

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  final List<String> categories = [
    "All",
    "Daily Use",
    "Electrical",
    "Agricultural",
  ];

  String selectedCategory = 'All';
  List<Map<String, dynamic>> productList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final allProducts = await DBHelper.instance.getAllProducts();
    setState(() {
      if (selectedCategory == 'All') {
        productList = allProducts;
      } else {
        productList =
            allProducts
                .where(
                  (product) =>
                      product['category']?.toString().trim().toLowerCase() ==
                      selectedCategory.toLowerCase(),
                )
                .toList();
      }
    });
  }

  Future<void> deleteProduct(int id) async {
    await DBHelper.instance.deleteProductById(id);
    fetchProducts();
  }

  void confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Product'),
            content: const Text(
              'Are you sure you want to delete this product?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteProduct(id);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void navigateToEditProduct(Map<String, dynamic> product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UpdateProduct(product: product)),
    );

    if (result == true) {
      fetchProducts();
    }
  }

  String _shortenDescription(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= 2) return text;
    return words.take(2).join(' ') + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 235, 235),
        title: const Text(
          'View Products',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Choose Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String category = categories[index];
                bool isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                      fetchProducts();
                    },
                    selectedColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                productList.isEmpty
                    ? const Center(child: Text("No products found"))
                    : ListView.builder(
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        return Card(
                          color: const Color.fromARGB(255, 234, 233, 233),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading:
                                product['image_path'] != null &&
                                        File(product['image_path']).existsSync()
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(product['image_path']),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : const Icon(Icons.image_not_supported),
                            title: Text(product['product_name'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("₹${product['product_price']}"),
                                Text("Qty: ${product['product_quantity']}"),
                                Text(
                                  "Category: ${product['category'] ?? 'N/A'}",
                                ),
                                Text(
                                  _shortenDescription(product['details'] ?? ''),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed:
                                      () => navigateToEditProduct(product),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed:
                                      () =>
                                          confirmDelete(context, product['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
