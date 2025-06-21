import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/database/data/local/db_helper.dart';
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
  String? selectedSubCategory;
  final Map<String, List<String>> subCategories = {
    "Agricultural": ["Hand Tools", "Irrigation Tools", "Cutting Tools"],
    "Electrical": ["Drills", "Multimeters", "Wiring Tools"],
    "Daily Use": ["Hammer", "Screwdriver", "Wrenches"],
  };

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
  }

  Future<void> fetchCategoryProducts() async {
    final allProducts = await DBHelper.instance.getAllProducts();
    setState(() {
      if (widget.category == null || widget.category == "All") {
        filteredProducts = allProducts;
      } else {
        filteredProducts =
            allProducts.where((product) {
              final matchesCategory = product['category'] == widget.category;
              final matchesSubCategory =
                  selectedSubCategory == null ||
                  product['sub_category'] == selectedSubCategory;
              return matchesCategory && matchesSubCategory;
            }).toList();
      }
    });
  }

  void _onSubCategorySelected(String? subCategory) {
    setState(() {
      selectedSubCategory = subCategory;
    });
    fetchCategoryProducts();
  }

  @override
  Widget build(BuildContext context) {
    final hasSubCategories =
        widget.category != null &&
        widget.category != "All" &&
        subCategories.containsKey(widget.category);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 240, 240),
      appBar: AppBar(
        title: Text(widget.category ?? 'All Products'),
        backgroundColor: const Color.fromARGB(255, 239, 237, 237),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          if (hasSubCategories) _buildSubCategoryFilter(),
          Expanded(
            child: Padding(
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryFilter() {
    final subCategoryItems = subCategories[widget.category] ?? [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "All" option
          _buildFilterButton(
            label: 'All',
            isSelected: selectedSubCategory == null,
            onTap: () => _onSubCategorySelected(null),
          ),
          const SizedBox(width: 8),
          // Subcategory options
          ...subCategoryItems.map((subCategory) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterButton(
                label: subCategory,
                isSelected: selectedSubCategory == subCategory,
                onTap: () => _onSubCategorySelected(subCategory),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
          ),
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
