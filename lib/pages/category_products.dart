import 'package:flutter/material.dart';
import 'package:second_project/pages/product_detail.dart';
import 'package:second_project/widget/support_widget.dart';

class CategoryProducts extends StatefulWidget {
  final String category;

  const CategoryProducts({super.key, required this.category});

  @override
  State<CategoryProducts> createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  // We will fetch this from a database in the future
  final List<Map<String, dynamic>> mockProducts = [
    {"name": "Drill", "price": "Nrs3000", "image": "assets/images/Drill.png"},
    {
      "name": "Screwdriver",
      "price": "Nrs200",
      "image": "assets/images/screwdriver.jpg",
    },
    {
      "name": "Side Cutters",
      "price": "Nrs400",
      "image": "assets/images/SideCutters.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 251, 251),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 251, 251),
        elevation: 0,
        title: Text(
          '${widget.category} Tools',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: mockProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final product = mockProducts[index];
            return GestureDetector(
              onTap: () {
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
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        product["image"],
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product["name"],
                      style: AppWidget.semiboldTextFieldStyle(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product["price"],
                          style: const TextStyle(
                            color: Color.fromARGB(135, 213, 91, 91),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 251, 72, 56),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
