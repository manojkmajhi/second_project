import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:intl/intl.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final orders = await DBHelper.instance.getOrdersByLoggedInUser();
    setState(() {
      _orders = orders;
    });
  }

  Future<void> _deleteOrder(int orderId) async {
    await DBHelper.instance.deleteOrderById(orderId);
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 251, 251),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 251, 251),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Your Orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          _orders.isEmpty
              ? const Center(
                child: Text(
                  'Your order is empty!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final formattedDate = DateFormat.yMMMd().add_jm().format(
                    DateTime.parse(
                      order['order_date'] ?? DateTime.now().toString(),
                    ),
                  );

                  // Decode products JSON
                  List<dynamic> items = [];
                  try {
                    items = jsonDecode(order['products']);
                  } catch (_) {}

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
                                Text("Total: Nrs. ${order['total_price']}"),
                                Text("Date: $formattedDate"),
                                Text("Status: ${order['status']}"),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteOrder(order['id']),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...items.map((item) {
                            final imagePath = item['image'];
                            final isNetworkImage =
                                imagePath != null &&
                                imagePath.startsWith('http');

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
                                      image: DecorationImage(
                                        image:
                                            isNetworkImage
                                                ? NetworkImage(imagePath)
                                                : AssetImage(
                                                      imagePath ??
                                                          'assets/images/default.png',
                                                    )
                                                    as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['product_name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Quantity: ${item['quantity'] ?? 1}",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
