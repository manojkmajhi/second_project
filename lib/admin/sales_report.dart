import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:second_project/database/data/local/db_helper.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final DBHelper _dbHelper = DBHelper.instance;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  double _totalSales = 0;
  String _selectedFilter = 'Today';
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'Today',
    'Yesterday',
    'This Month',
    'This Year',
    'Total',
  ];

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    setState(() => _isLoading = true);

    try {
      _orders = await _dbHelper.getAllOrders();
      debugPrint('Total orders fetched: ${_orders.length}');

      // Debug: Print all orders with their status
      for (var order in _orders) {
        debugPrint(
          'Order ID: ${order['id']}, Status: ${order['status']}, Date: ${order['order_date']}',
        );
      }

      // Filter only completed orders (case insensitive)
      _orders =
          _orders.where((order) {
            final status = order['status']?.toString().toLowerCase();
            return status == 'completed' || status == 'delivered';
          }).toList();

      debugPrint('Completed orders: ${_orders.length}');
      _applyFilter(_selectedFilter);
    } catch (e) {
      debugPrint('Error fetching sales data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      final now = DateTime.now();
      _filteredOrders = [];

      switch (filter) {
        case 'Today':
          _filteredOrders =
              _orders.where((order) {
                try {
                  final orderDate = DateTime.parse(
                    order['order_date'].toString(),
                  );
                  return orderDate.year == now.year &&
                      orderDate.month == now.month &&
                      orderDate.day == now.day;
                } catch (e) {
                  debugPrint('Error parsing date: ${order['order_date']}, $e');
                  return false;
                }
              }).toList();
          break;

        case 'Yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          _filteredOrders =
              _orders.where((order) {
                try {
                  final orderDate = DateTime.parse(
                    order['order_date'].toString(),
                  );
                  return orderDate.year == yesterday.year &&
                      orderDate.month == yesterday.month &&
                      orderDate.day == yesterday.day;
                } catch (e) {
                  debugPrint('Error parsing date: ${order['order_date']}, $e');
                  return false;
                }
              }).toList();
          break;

        case 'This Month':
          _filteredOrders =
              _orders.where((order) {
                try {
                  final orderDate = DateTime.parse(
                    order['order_date'].toString(),
                  );
                  return orderDate.year == now.year &&
                      orderDate.month == now.month;
                } catch (e) {
                  debugPrint('Error parsing date: ${order['order_date']}, $e');
                  return false;
                }
              }).toList();
          break;

        case 'This Year':
          _filteredOrders =
              _orders.where((order) {
                try {
                  final orderDate = DateTime.parse(
                    order['order_date'].toString(),
                  );
                  return orderDate.year == now.year;
                } catch (e) {
                  debugPrint('Error parsing date: ${order['order_date']}, $e');
                  return false;
                }
              }).toList();
          break;

        case 'Total':
          _filteredOrders = List.from(_orders);
          break;
      }

      // Sort orders by date (newest first)
      _filteredOrders.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['order_date'].toString());
          final dateB = DateTime.parse(b['order_date'].toString());
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      _calculateTotalSales();
    });
  }

  void _calculateTotalSales() {
    _totalSales = _filteredOrders.fold(0.0, (sum, order) {
      final price = order['total_price'];
      return sum + (price is num ? price.toDouble() : 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sales Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildFilterDropdown(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSummaryCard(),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Order History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredOrders.length} items',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSalesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        value: _selectedFilter,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        decoration: InputDecoration(
          labelText: 'Filter period',
          labelStyle: const TextStyle(color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        dropdownColor: Colors.white,
        items:
            _filterOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
        onChanged: (value) => _applyFilter(value!),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_selectedFilter Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    'Total Orders',
                    _filteredOrders.length.toString(),
                    Icons.receipt,
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Total Sales',
                    'Nrs.${_totalSales.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesList() {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No sales data available',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            Text(
              'for the selected period',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredOrders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        DateTime orderDate;

        try {
          orderDate = DateTime.parse(order['order_date'].toString());
        } catch (e) {
          debugPrint('Error parsing date: ${order['order_date']}, $e');
          orderDate = DateTime.now();
        }

        final formattedDate = DateFormat(
          'MMM dd, yyyy - hh:mm a',
        ).format(orderDate);

        return Container(
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.green),
            ),
            title: Text(
              'Order #${order['id']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (order['customer_name'] != null)
                  Text(
                    'Customer: ${order['customer_name']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Nrs.${(order['total_price'] is num ? (order['total_price'] as num).toStringAsFixed(2) : '0.00')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']?.toString() ?? ''),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status']?.toString() ?? 'N/A',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'delivered':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
