import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedStatus = 'Pending';
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final allOrders = await DBHelper.instance.getOrdersByLoggedInUser();
    setState(() {
      _orders =
          allOrders
              .where(
                (order) =>
                    (order['status'] ?? 'Pending').toString().toLowerCase() ==
                    _selectedStatus.toLowerCase(),
              )
              .toList();
    });
  }

  Future<void> _deleteOrder(int orderId) async {
    await DBHelper.instance.deleteOrderById(orderId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🗑️ Order deleted')));
    await _fetchOrders();
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<String>(
      value: _selectedStatus,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      icon: const Icon(Icons.arrow_drop_down),
      items: const [
        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
        DropdownMenuItem(value: 'Completed', child: Text('Completed')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
          _fetchOrders();
        }
      },
    );
  }
 


  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          "Order ID: ${order['id']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User ID: ${order['user_id']}"),
            Text("Total Price: Rs ${order['total_price']}"),
            Text("Date: ${order['order_date']}"),
            Text("Status: ${order['status'] ?? 'Pending'}"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteOrder(order['id']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' All Orders'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 235, 235, 235)  ,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildStatusDropdown()],
            ),
            const Divider(),
            Expanded(
              child:
                  _orders.isEmpty
                      ? const Center(child: Text("No orders found."))
                      : ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(_orders[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
