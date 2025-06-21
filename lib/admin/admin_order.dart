import 'package:flutter/material.dart';
import 'package:second_project/database/data/local/db_helper.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedStatus = 'Pending';
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final allOrders = await DBHelper.instance.getAllOrders();
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

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    await DBHelper.instance.updateOrderStatus(orderId, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Order status updated to $newStatus')),
    );
    await _fetchOrders();
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<String>(
      value: _selectedStatus,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      icon: const Icon(Icons.arrow_drop_down),
      items: const [
        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
        DropdownMenuItem(value: 'In Process', child: Text('In Process')),
        DropdownMenuItem(value: 'Completed', child: Text('Completed')),
        DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
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

  Widget _buildStatusUpdateDropdown(Map<String, dynamic> order) {
    final List<String> statusOptions = [
      'Pending',
      'In Process',
      'Completed',
      'Cancelled',
    ];
    String currentStatus = statusOptions.firstWhere(
      (status) =>
          status.toLowerCase() ==
          (order['status'] ?? 'Pending').toString().toLowerCase(),
      orElse: () => 'Pending',
    );

    return DropdownButton<String>(
      value: currentStatus,
      icon: const Icon(Icons.arrow_drop_down, size: 20),
      elevation: 4,
      style: TextStyle(
        color: _getStatusColor(currentStatus),
        fontWeight: FontWeight.bold,
      ),
      items:
          statusOptions
              .map(
                (String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
      onChanged: (String? newValue) {
        if (newValue != null && newValue != currentStatus) {
          _updateOrderStatus(order['id'], newValue);
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in process':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order['id']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteOrder(order['id']),
                ),
              ],
            ),
            const Divider(),
            _buildOrderDetailRow("Customer:", order['customer_name']),
            _buildOrderDetailRow("Email:", order['customer_email']),
            _buildOrderDetailRow("Phone:", order['customer_phone']),
            const SizedBox(height: 8),
            _buildOrderDetailRow("User ID:", order['user_id'].toString()),
            _buildOrderDetailRow("Total:", "Rs ${order['total_price']}"),
            _buildOrderDetailRow("Payment:", order['payment_method']),
            _buildOrderDetailRow("Date:", _formatDate(order['order_date'])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status: ${order['status'] ?? 'Pending'}",
                  style: TextStyle(
                    color: _getStatusColor(order['status'] ?? 'Pending'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusUpdateDropdown(order),
              ],
            ),
            if (order['delivery_address'] != null) ...[
              const SizedBox(height: 8),
              Text(
                "Delivery Address:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(order['delivery_address']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'Not available',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 251, 251),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'All Orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
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
