import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:second_project/pages/category_products.dart';
import 'package:second_project/pages/product_details/screen/product_detail.dart';
import 'package:second_project/pages/search.dart';
import 'package:second_project/widget/support_widget.dart';
import 'package:second_project/database/data/local/db_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> categories = ["All", "Daily Use", "Electrical", "Agricultural"];
  List<Map<String, dynamic>> products = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final result = await DBHelper.instance.getAllProducts();
    setState(() {
      products = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      body: Container(
        margin: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, ...",
                            style: AppWidget.boldTextFieldStyle(),
                          ),
                          Text(
                            "Welcome to ToolKit",
                            style: AppWidget.lightTextFieldStyle(),
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        !snapshot.data!.exists) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, User",
                            style: AppWidget.boldTextFieldStyle(),
                          ),
                          Text(
                            "Welcome to ToolKit",
                            style: AppWidget.lightTextFieldStyle(),
                          ),
                        ],
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'User';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $name",
                          style: AppWidget.boldTextFieldStyle(),
                        ),
                        Text(
                          "Welcome to ToolKit",
                          style: AppWidget.lightTextFieldStyle(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search your tools",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (query) {
                        if (query.trim().isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SearchPage(initialQuery: query),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (searchController.text.trim().isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SearchPage(
                                  initialQuery: searchController.text,
                                ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20.0),

            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Categories", style: AppWidget.semiboldTextFieldStyle()),
              ],
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              height: 50,
              child: ListView.builder(
                itemCount: categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return CategoryButton(categoryName: categories[index]);
                },
              ),
            ),

            const SizedBox(height: 20.0),

            // Products Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Products", style: AppWidget.semiboldTextFieldStyle()),
              ],
            ),

            // Product List
            Expanded(
              child:
                  products.isEmpty
                      ? const Center(
                        child: Text(
                          "No products available",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        itemCount: (products.length / 2).ceil(),
                        itemBuilder: (context, rowIndex) {
                          final index1 = rowIndex * 2;
                          final index2 = index1 + 1;
                          final product1 = products[index1];
                          final product2 =
                              index2 < products.length
                                  ? products[index2]
                                  : null;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Expanded(child: productCard(context, product1)),
                                const SizedBox(width: 16),
                                if (product2 != null)
                                  Expanded(
                                    child: productCard(context, product2),
                                  )
                                else
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productCard(BuildContext context, Map<String, dynamic> product) {
    final isOutOfStock = (product['product_quantity'] ?? 0) <= 0;

    return GestureDetector(
      onTap:
          isOutOfStock
              ? null
              : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetail(product: product),
                  ),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product['image_path'] != null &&
                      File(product['image_path']).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(product['image_path']),
                        height: 95,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      product['product_name'] ?? 'Unnamed Product',
                      style: AppWidget.semiboldTextFieldStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: Nrs.${product['product_price']}",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 213, 91, 91),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Category: ${product['category'] ?? 'Unknown'}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (isOutOfStock) const SizedBox(height: 8),
                ],
              ),
            ),
            if (isOutOfStock)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Text(
                        "OUT OF STOCK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String categoryName;

  const CategoryButton({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CategoryProducts(
                  category: categoryName == "All" ? null : categoryName,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        margin: const EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            categoryName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
