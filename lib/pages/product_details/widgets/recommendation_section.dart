import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/pages/product_details/screen/product_detail.dart';


class RecommendationSection extends StatelessWidget {
  final List<Map<String, dynamic>> recommended;

  const RecommendationSection({super.key, required this.recommended});

  @override
  Widget build(BuildContext context) {
    if (recommended.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recommended for You", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommended.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final p = recommended[index];
              final imageWidget = p['image_path'] != null && File(p['image_path']).existsSync()
                  ? Image.file(File(p['image_path']), fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, size: 50);

              return GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetail(product: p)),
                ),
                child: Container(
                  width: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(2, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: SizedBox(height: 90, width: double.infinity, child: imageWidget),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(p['product_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Nrs. ${p['product_price'] ?? ''}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
