import 'package:flutter/material.dart';
import 'package:second_project/database/data/local/db_helper.dart';
import 'package:second_project/pages/order/model/order_model.dart';
import 'package:second_project/pages/order/widget/order_card.dart';

import 'package:second_project/pages/order/widget/order_filter_buttons.dart';


class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final ordersData = await DBHelper.instance.getOrdersByLoggedInUser();
    setState(() {
      _allOrders =
          ordersData.map((map) => OrderModel.fromMap(map)).toList();
      _applyFilter();
    });
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders = _allOrders.where((order) {
          return order.status.toLowerCase() == _selectedFilter.toLowerCase();
        }).toList();
      }
    });
  }

  Future<void> _cancelOrder(int? orderId) async {
    if (orderId != null) {
      await DBHelper.instance.deleteOrderById(orderId);
      await _fetchOrders();
    }
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
          OrderFilterButtons(
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
                _applyFilter();
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _filteredOrders.isEmpty
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
                      return OrderCard(
                        order: order,
                        onCancel: _cancelOrder,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}