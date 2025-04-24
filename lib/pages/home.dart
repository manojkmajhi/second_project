import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/pages/category_products.dart';
import 'package:second_project/pages/product_detail.dart';
import 'package:second_project/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> categories = ['All', 'Daily Use', 'Electronics', 'Agriculture'];

  List<Map<String, dynamic>> products = [];

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
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi, User", style: AppWidget.boldTextFieldStyle()),
                    Text(
                      "Welcome to ToolKit",
                      style: AppWidget.lightTextFieldStyle(),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset(
                    "assets/logo/user.png",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            /// Search
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search your tools",
                  hintStyle: AppWidget.lightTextFieldStyle(),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            /// Categories
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

            /// Products Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Products", style: AppWidget.semiboldTextFieldStyle()),
              ],
            ),

            /// Products Displayed
            Expanded(
              child:
                  products.isEmpty
                      ? const Center(child: Text("No products available"))
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

                          return Row(
                            children: [
                              Expanded(child: productCard(context, product1)),
                              const SizedBox(width: 16),
                              if (product2 != null)
                                Expanded(child: productCard(context, product2))
                              else
                                const Expanded(child: SizedBox()),
                            ],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetail(product: product), // ✅ Fixed
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product['image_path'] != null &&
                File(product['image_path']).existsSync())
              Image.file(
                File(product['image_path']),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 100,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                product['product_name'] ?? '',
                style: AppWidget.semiboldTextFieldStyle(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: ₹${product['product_price']}",
              style: const TextStyle(
                color: Color.fromARGB(135, 213, 91, 91),
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
            builder: (context) => CategoryProducts(category: categoryName),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        margin: const EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.0),
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
