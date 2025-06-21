import 'package:flutter/material.dart';
import 'package:second_project/pages/product_details/screen/product_detail.dart';
import 'dart:io';

import '../database/data/local/db_helper.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;

  const SearchPage({super.key, required this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    searchProduct(widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void searchProduct(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final allProducts = await DBHelper.instance.getAllProducts();
    final results =
        allProducts.where((product) {
          final name = product['product_name'].toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();

    setState(() {
      searchResults = results;
    });
  }

  void navigateToProductDetails(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetail(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 235, 235),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                searchProduct(_searchController.text);
              },
            ),
          ),
          onSubmitted: (value) {
            searchProduct(value);
          },
        ),
      ),
      body:
          searchResults.isEmpty
              ? const Center(child: Text("No products found."))
              : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final product = searchResults[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),

                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      child: ListTile(
                        onTap: () => navigateToProductDetails(product),
                        leading:
                            (product['image_path'] != null &&
                                    File(product['image_path']).existsSync())
                                ? Image.file(
                                  File(product['image_path']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                        title: Text(
                          product['product_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Price: Nrs.${product['product_price']}",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
