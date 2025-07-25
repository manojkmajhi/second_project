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
  String _selectedFilter = 'Total';
  String? _selectedPaymentMethod;
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'Today',
    'Yesterday',
    'This Month',
    'This Year',
    'Total',
  ];

  final List<String> _paymentMethods = ['All', 'Cash on Delivery', 'Khalti'];

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

      // Filter only completed orders (case insensitive)
      _orders =
          _orders.where((order) {
            final status = order['status']?.toString().toLowerCase();
            return status == 'completed' || status == 'delivered';
          }).toList();

      debugPrint('Completed orders: ${_orders.length}');
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching sales data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      final now = DateTime.now();
      _filteredOrders =
          _orders.where((order) {
            // Apply time filter
            bool timeFilter = false;
            try {
              final orderDate = DateTime.parse(order['order_date'].toString());

              switch (_selectedFilter) {
                case 'Today':
                  timeFilter =
                      orderDate.year == now.year &&
                      orderDate.month == now.month &&
                      orderDate.day == now.day;
                  break;
                case 'Yesterday':
                  final yesterday = now.subtract(const Duration(days: 1));
                  timeFilter =
                      orderDate.year == yesterday.year &&
                      orderDate.month == yesterday.month &&
                      orderDate.day == yesterday.day;
                  break;
                case 'This Month':
                  timeFilter =
                      orderDate.year == now.year &&
                      orderDate.month == now.month;
                  break;
                case 'This Year':
                  timeFilter = orderDate.year == now.year;
                  break;
                case 'Total':
                  timeFilter = true;
                  break;
              }
            } catch (e) {
              debugPrint('Error parsing date: ${order['order_date']}, $e');
              return false;
            }

            // Apply payment method filter if selected
            bool paymentFilter = true;
            if (_selectedPaymentMethod != null &&
                _selectedPaymentMethod != 'All') {
              paymentFilter = order['payment_method'] == _selectedPaymentMethod;
            }

            return timeFilter && paymentFilter;
          }).toList();

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
            child: Column(
              children: [
                _buildFilterDropdown(
                  label: 'Filter period',
                  value: _selectedFilter,
                  items: _filterOptions,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterDropdown(
                  label: 'Payment method',
                  value: _selectedPaymentMethod ?? 'All',
                  items: _paymentMethods,
                  onChanged: (value) {
                    setState(
                      () =>
                          _selectedPaymentMethod =
                              value == 'All' ? null : value,
                    );
                    _applyFilters();
                  },
                ),
              ],
            ),
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

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        dropdownColor: Colors.white,
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
        onChanged: onChanged,
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
                '$_selectedFilter Summary${_selectedPaymentMethod != null ? ' (${_selectedPaymentMethod})' : ''}',
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
                    Icons.money,
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
              'for the selected filters',
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
                Text(
                  'Payment: ${order['payment_method'] ?? 'N/A'}',
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
