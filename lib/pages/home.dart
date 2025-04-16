import 'dart:math';
import 'package:flutter/material.dart';
import 'package:second_project/pages/category_products.dart';
import 'package:second_project/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> categories = [
    "Agriculture",
    "Daily Use",
    "Electrical",
    "Construction",
  ];

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
                const Text(
                  "See All",
                  style: TextStyle(color: Color.fromARGB(135, 213, 91, 91)),
                ),
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

            /// Products Displayed (Vertically)
            Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: productCard(
                          "Drill",
                          "Nrs3000",
                          "assets/images/Drill.png",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: productCard(
                          "Screw Driver",
                          "Nrs200",
                          "assets/images/screwdriver.jpg",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: productCard(
                          "Side Cutters",
                          "Nrs200",
                          "assets/images/SideCutters.png",
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()), // Empty space
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

  Widget productCard(String name, String price, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 10),
          Center(child: Text(name, style: AppWidget.semiboldTextFieldStyle())),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color.fromARGB(135, 213, 91, 91),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 72, 56),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
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
