import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/pages/review_order_screen.dart';

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

  Future<void> _cancelOrder(int orderId) async {
    await DBHelper.instance.deleteOrderById(orderId);
    await _fetchOrders();
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
                        } catch (e) {
                          debugPrint('Error parsing products: $e');
                        }

                        final status =
                            order['status']?.toString().toLowerCase().trim() ??
                            'pending';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                                  ),
                                  const SizedBox(height: 10),
                                  ...items.map((item) {
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: _buildProductImage(
                                                item['image']?.toString(),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['product_name'] ??
                                                      'Unknown Product',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "Quantity: ${item['quantity'] ?? 1}",
                                                ),
                                                if (item['product_price'] !=
                                                    null)
                                                  Text(
                                                    "Price: Nrs.${item['product_price']}",
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
                                        onPressed:
                                            () => _cancelOrder(order['id']),
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
                                              builder:
                                                  (context) =>
                                                      ReviewOrderScreen(
                                                        products: List<
                                                          Map<String, dynamic>
                                                        >.from(items),
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
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
