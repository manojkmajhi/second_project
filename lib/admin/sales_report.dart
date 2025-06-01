import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:second_project/data/local/db_helper.dart';

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
            return status == 'completed' ||
                status == 'delivered'; // Include both statuses if needed
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
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 251, 251),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Sales Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterDropdown(),
          _buildSummaryCard(),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedFilter,
        items:
            _filterOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (value) => _applyFilter(value!),
        decoration: const InputDecoration(
          labelText: 'Filter by',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '$_selectedFilter Sales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${_filteredOrders.length} Orders',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Total: Nrs.${_totalSales.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesList() {
    if (_filteredOrders.isEmpty) {
      return const Center(
        child: Text('No sales data available for the selected period'),
      );
    }

    return ListView.builder(
      itemCount: _filteredOrders.length,
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

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text('Order #${order['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate),
                Text('Customer: ${order['customer_name'] ?? 'N/A'}'),
                Text('Status: ${order['status'] ?? 'N/A'}'),
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
                Text(
                  'Qty: ${order['quantity'] ?? '1'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
