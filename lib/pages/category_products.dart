import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/pages/product_details/screen/product_detail.dart';
import 'package:second_project/widget/support_widget.dart';

class CategoryProducts extends StatefulWidget {
  final String? category;

  const CategoryProducts({super.key, this.category});

  @override
  State<CategoryProducts> createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
  }

  Future<void> fetchCategoryProducts() async {
    final allProducts = await DBHelper.instance.getAllProducts();
    setState(() {
      if (widget.category == null || widget.category == "All") {
        // Show all products if category is null or "All"
        filteredProducts = allProducts;
      } else {
        // Filter by specific category
        filteredProducts =
            allProducts
                .where((product) => product['category'] == widget.category)
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 240, 240),
      appBar: AppBar(
        title: Text(widget.category ?? 'All Products'), // Handle null case
        backgroundColor: const Color.fromARGB(255, 239, 237, 237),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            filteredProducts.isEmpty
                ? const Center(
                  child: Text(
                    "No products available",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return productCard(context, filteredProducts[index]);
                  },
                ),
      ),
    );
  }

  Widget productCard(BuildContext context, Map<String, dynamic> product) {
    final imageExists =
        product['image_path'] != null &&
        File(product['image_path']).existsSync();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetail(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
                child:
                    imageExists
                        ? Image.file(
                          File(product['image_path']),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['product_name'] ?? 'Unnamed Product',
                    style: AppWidget.semiboldTextFieldStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Nrs. ${product['product_price']}",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 213, 91, 91),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'] ?? 'Uncategorized',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
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
