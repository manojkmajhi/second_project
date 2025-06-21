import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second_project/pages/cart/model/cart_product_model.dart'; 

class CartItemCard extends StatelessWidget {
  final CartProductModel product;
  final bool isSelected;
  final VoidCallback onToggleSelected;
  final VoidCallback onRemove;
  final Function(int change) onUpdateQuantity;

  const CartItemCard({
    Key? key,
    required this.product,
    required this.isSelected,
    required this.onToggleSelected,
    required this.onRemove,
    required this.onUpdateQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool imageExists = false;
    if (product.imagePath != null) {
      try {
        imageExists = File(product.imagePath!).existsSync();
      } catch (e) {
        imageExists = false;
        debugPrint("Error checking image existence: $e");
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          // Checkbox for selection
          Checkbox(
            value: isSelected,
            onChanged: (bool? value) => onToggleSelected(),
          ),
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageExists
                ? Image.file(
                    File(product.imagePath!),
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/logo/ToolKit_logo.png", // Fallback image
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          // Product Details (Name, Price, Quantity controls)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Nrs.${product.productPrice.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => onUpdateQuantity(-1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${product.quantity}'),
                    IconButton(
                      onPressed: () => onUpdateQuantity(1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Total price for the item and delete button
          Column(
            children: [
              Text(
                "Nrs.${(product.productPrice * product.quantity).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}