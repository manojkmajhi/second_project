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
  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final orders = await DBHelper.instance.getOrdersByLoggedInUser();
    setState(() {
      _allOrders = orders;
      _applyFilter();
    });
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders =
            _allOrders.where((order) {
              return (order['status'] ?? 'pending').toString().toLowerCase() ==
                  _selectedFilter.toLowerCase();
            }).toList();
      }
    });
  }

  Future<void> _deleteOrder(int orderId) async {
    await DBHelper.instance.deleteOrderById(orderId);
    await _fetchOrders();
  }

  String _getStatusButtonLabel(dynamic status) {
    final statusStr = status?.toString().toLowerCase() ?? 'pending';
    switch (statusStr) {
      case 'completed':
        return 'Review';
      case 'in process':
        return 'On the Way';
      default:
        return '';
    }
  }

  Color _getStatusButtonColor(dynamic status) {
    final statusStr = status?.toString().toLowerCase() ?? 'pending';
    switch (statusStr) {
      case 'completed':
        return Colors.green;
      case 'in process':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Widget _buildFilterButtons() {
    const filters = ['All', 'Pending', 'In Process', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children:
            filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.black : Colors.grey[300],
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedFilter = filter;
                      _applyFilter();
                    });
                  },
                  child: Text(filter),
                ),
              );
            }).toList(),
      ),
    );
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildFilterButtons(),
          const SizedBox(height: 10),
          Expanded(
            child:
                _filteredOrders.isEmpty
                    ? const Center(
                      child: Text(
                        'No orders found!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        final formattedDate = DateFormat.yMMMd()
                            .add_jm()
                            .format(
                              DateTime.parse(
                                order['order_date'] ??
                                    DateTime.now().toString(),
                              ),
                            );

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total: Nrs. ${order['total_price']}",
                                      ),
                                      Text("Date: $formattedDate"),
                                      Text("Status: ${order['status']}"),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          margin: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                if (order['status'] != null &&
                                    order['status'].toString().toLowerCase() !=
                                        'pending')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              _getStatusButtonColor(
                                                order['status'],
                                              ),
                                        ),
                                        onPressed: () {
                                          final status =
                                              order['status']
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              '';
                                          if (status == 'completed') {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  '🔍 Review this order',
                                                ),
                                              ),
                                            );
                                          } else if (status == 'in process') {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  '🚚 Your order is on the way!',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          _getStatusButtonLabel(
                                            order['status'],
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
