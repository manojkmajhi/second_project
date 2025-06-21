import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:second_project/pages/order/model/order_model.dart';
import 'package:second_project/pages/review_order_screen.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(int?) onCancel;

  const OrderCard({
    super.key,
    required this.order,
    required this.onCancel,
  });

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset(
        'assets/images/default.png',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    }

    return Image.asset(
      imagePath,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
    );
  }

  Widget _buildDefaultImage() {
    return Image.asset(
      'assets/images/default.png',
      width: 60,
      height: 60,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().add_jm().format(order.orderDate);
    final status = order.status.toLowerCase().trim();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total: Nrs. ${order.totalPrice.toStringAsFixed(2)}",
                    ),
                    Text("Date: $formattedDate"),
                    Text("Status: ${order.status}"),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...order.products.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildProductImage(item.image),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Quantity: ${item.quantity}"),
                            if (item.productPrice != null)
                              Text(
                                "Price: Nrs.${item.productPrice!.toStringAsFixed(2)}",
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              if (status == 'pending')
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => onCancel(order.id),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              else if (status == 'completed')
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewOrderScreen(
                            products: order.products
                                .map((item) => {
                                      'product_name': item.productName,
                                      'quantity': item.quantity,
                                      'product_price': item.productPrice,
                                      'image': item.image,
                                    })
                                .toList(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Add Review',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}