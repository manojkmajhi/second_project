import 'dart:io';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:second_project/pages/product_details/screen/product_detail.dart';

class RecommendationSection extends StatelessWidget {
  final List<Map<String, dynamic>> recommended;
  final Map<String, dynamic>? currentProduct;

  const RecommendationSection({
    super.key,
    required this.recommended,
    this.currentProduct,
  });

  double _cosineSimilarity(
    Map<String, dynamic> productA,
    Map<String, dynamic> productB,
    List<String> featureFields,
  ) {
    final featuresA =
        featureFields
            .map((field) => productA[field]?.toString().toLowerCase() ?? '')
            .toList();
    final featuresB =
        featureFields
            .map((field) => productB[field]?.toString().toLowerCase() ?? '')
            .toList();

    final allTerms =
        {...featuresA, ...featuresB}.where((term) => term.isNotEmpty).toList();
    if (allTerms.isEmpty) return 0.0;

    final vectorA =
        allTerms
            .map((term) => featuresA.where((f) => f == term).length)
            .toList();
    final vectorB =
        allTerms
            .map((term) => featuresB.where((f) => f == term).length)
            .toList();

    double dotProduct = 0.0;
    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i].toDouble();
    }

    double magnitudeA = 0.0;
    double magnitudeB = 0.0;
    for (int i = 0; i < vectorA.length; i++) {
      magnitudeA += vectorA[i] * vectorA[i];
      magnitudeB += vectorB[i] * vectorB[i];
    }
    magnitudeA = Math.sqrt(magnitudeA);
    magnitudeB = Math.sqrt(magnitudeB);

    if (magnitudeA == 0.0 || magnitudeB == 0.0) return 0.0;

    return dotProduct / (magnitudeA * magnitudeB);
  }

  List<Map<String, dynamic>> _getSortedRecommendations() {
    if (currentProduct == null || recommended.isEmpty) return recommended;

    const featureFields = ['category', 'sub_category', 'brand', 'keywords'];

    final scoredProducts =
        recommended.map((product) {
          final similarity = _cosineSimilarity(
            currentProduct!,
            product,
            featureFields,
          );
          return {'product': product, 'similarity': similarity};
        }).toList();

    scoredProducts.sort((a, b) {
      final aScore = a['similarity'] as double;
      final bScore = b['similarity'] as double;
      return bScore.compareTo(aScore);
    });

    return scoredProducts
        .where((e) => (e['similarity'] as double) > 0.0)
        .where((e) => e['product'] != currentProduct)
        .map((e) => e['product'] as Map<String, dynamic>)
        .toList();
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final isOutOfStock = (product['product_quantity'] ?? 0) <= 0;

    return GestureDetector(
      onTap:
          isOutOfStock
              ? null
              : () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetail(product: product),
                ),
              ),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 90,
                    width: double.infinity,
                    child:
                        product['image_path'] != null &&
                                File(product['image_path']).existsSync()
                            ? Image.file(
                              File(product['image_path']),
                              fit: BoxFit.cover,
                            )
                            : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['product_name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Nrs. ${product['product_price'] ?? ''}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isOutOfStock)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "OUT OF STOCK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    final sortedRecommendations = _getSortedRecommendations();

    if (sortedRecommendations.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Recommended for You",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: sortedRecommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildProductCard(context, sortedRecommendations[index]);
            },
          ),
        ),
      ],
    );
  }
}

// ==================== RECOMMENDATION ====================
// Future<List<Map<String, dynamic>>> getRecommendedProducts(
//   String category,
//   int currentProductId, {
//   String? productName,
//   String? details,
// }) async {
//   final db = await getDB();
  
//   // First try to get products from same category
//   List<Map<String, dynamic>> allProducts = await db.query(
//     productTableName,
//     where: 'id != ? AND category = ?',
//     whereArgs: [currentProductId, category],
//     limit: 20, // Limit results for better performance
//   );

//   // If not enough products in same category, get any products
//   if (allProducts.length < 5) {
//     final moreProducts = await db.query(
//       productTableName,
//       where: 'id != ?',
//       whereArgs: [currentProductId],
//       limit: 20 - allProducts.length,
//     );
//     allProducts = [...allProducts, ...moreProducts];
//   }

//   // If no details provided, return shuffled products
//   if (details == null || details.trim().isEmpty) {
//     return allProducts..shuffle();
//   }

//   // Get current product details
//   final currentProduct = await db.query(
//     productTableName,
//     where: 'id = ?',
//     whereArgs: [currentProductId],
//   );
  
//   if (currentProduct.isEmpty) {
//     return allProducts..shuffle();
//   }

//   // Prepare text for comparison
//   final currentText = _prepareComparisonText(currentProduct.first);
//   final currentTokens = _preprocessText(currentText);

//   // Calculate similarities  
//   final productsWithSimilarity = await _calculateSimilarities(
//     allProducts,
//     currentTokens,
//   );

//   // Sort by similarity (descending) and take top 5
//   productsWithSimilarity.sort((a, b) => 
//     (b['similarity'] as double).compareTo(a['similarity'] as double));

//   // Ensure we always return some recommendations
//   final recommended = productsWithSimilarity.take(5).toList();
  
//   // If no good matches, return random products
//   if (recommended.isEmpty || recommended.first['similarity'] < 0.1) {
//     return allProducts..shuffle()..take(5).toList();
//   }

//   return recommended.map((p) {
//     final map = Map<String, dynamic>.from(p);
//     map.remove('similarity');
//     return map;
//   }).toList();
// }

// String _prepareComparisonText(Map<String, dynamic> product) {
//   return [
//     product['product_name'] ?? '',
//     product['details'] ?? '',
//     product['category'] ?? '',
//   ].join(' ').toLowerCase();
// }

// Future<List<Map<String, dynamic>>> _calculateSimilarities(
//   List<Map<String, dynamic>> products,
//   Set<String> currentTokens,
// ) async {
//   final List<Map<String, dynamic>> results = [];
  
//   for (var product in products) {
//     final productText = _prepareComparisonText(product);
//     final productTokens = _preprocessText(productText);
//     final similarity = _cosineSimilarity(currentTokens, productTokens);
    
//     results.add({
//       ...product,
//       'similarity': similarity,
//     });
//   }
  
//   return results;
// }

// Set<String> _preprocessText(String text) {
//   // Basic stop words to ignore
//   const stopWords = {
//     'the', 'and', 'a', 'an', 'in', 'on', 'at', 'to', 'for', 'of', 'with'
//   };
  
//   return text
//       .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
//       .toLowerCase()
//       .split(' ')
//       .where((word) => word.length > 2) // Ignore short words
//       .where((word) => !stopWords.contains(word)) // Remove stop words
//       .toSet();
// }

// double _cosineSimilarity(Set<String> tokensA, Set<String> tokensB) {
//   if (tokensA.isEmpty || tokensB.isEmpty) return 0.0;
  
//   final intersection = tokensA.intersection(tokensB).length;
//   final magnitudeA = sqrt(tokensA.length);
//   final magnitudeB = sqrt(tokensB.length);
  
//   return intersection / (magnitudeA * magnitudeB);
// }