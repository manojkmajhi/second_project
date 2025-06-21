import 'dart:convert';

import 'package:flutter/material.dart';

class OrderModel {
  final int? id;
  final double totalPrice;
  final DateTime orderDate;
  final String status;
  final List<ProductItem> products;

  OrderModel({
    this.id,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    required this.products,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    List<ProductItem> items = [];
    try {
      if (map['products'] != null) {
        // Handle both String (JSON) and List<dynamic> for products
        if (map['products'] is String) {
          items = (jsonDecode(map['products']) as List<dynamic>)
              .map((item) => ProductItem.fromMap(item))
              .toList();
        } else if (map['products'] is List) {
          items = (map['products'] as List<dynamic>)
              .map((item) => ProductItem.fromMap(item))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error parsing products in OrderModel: $e');
    }

    return OrderModel(
      id: map['id'],
      totalPrice: (map['total_price'] as num).toDouble(),
      orderDate: DateTime.parse(map['order_date'] ?? DateTime.now().toString()),
      status: map['status'] ?? 'pending',
      products: items,
    );
  }
}

class ProductItem {
  final String productName;
  final int quantity;
  final double? productPrice;
  final String? image;

  ProductItem({
    required this.productName,
    required this.quantity,
    this.productPrice,
    this.image,
  });

  factory ProductItem.fromMap(Map<String, dynamic> map) {
    return ProductItem(
      productName: map['product_name'] ?? 'Unknown Product',
      quantity: map['quantity'] ?? 1,
      productPrice: (map['product_price'] as num?)?.toDouble(),
      image: map['image']?.toString(),
    );
  }
}
