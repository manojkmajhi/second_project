import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/pages/product_detail.dart';
import 'package:second_project/widget/support_widget.dart';

class CategoryProducts extends StatefulWidget {
  final String category;

  const CategoryProducts({super.key, required this.category});

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
      filteredProducts =
          allProducts
              .where((product) => product['category'] == widget.category)
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            filteredProducts.isEmpty
                ? const Center(child: Text("No products in this category"))
                : ListView.builder(
                  itemCount: (filteredProducts.length / 2).ceil(),
                  itemBuilder: (context, rowIndex) {
                    final index1 = rowIndex * 2;
                    final index2 = index1 + 1;
                    final product1 = filteredProducts[index1];
                    final product2 =
                        index2 < filteredProducts.length
                            ? filteredProducts[index2]
                            : null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(child: productCard(context, product1)),
                          const SizedBox(width: 16),
                          if (product2 != null)
                            Expanded(child: productCard(context, product2))
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    );
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
        padding: const EdgeInsets.all(12.0),
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
            imageExists
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(product['image_path']),
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                : Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                product['product_name'] ?? '',
                style: AppWidget.semiboldTextFieldStyle(),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: ₹${product['product_price']}",
              style: const TextStyle(
                color: Color.fromARGB(255, 213, 91, 91),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Category: ${product['category'] ?? 'Unknown'}",
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
