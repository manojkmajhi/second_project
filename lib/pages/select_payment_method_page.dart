import 'package:flutter/material.dart';

class SelectPaymentMethodPage extends StatefulWidget {
  final String? selectedMethod;

  const SelectPaymentMethodPage({super.key, this.selectedMethod});

  @override
  State<SelectPaymentMethodPage> createState() =>
      _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  late String? _selectedMethod;
  final List<String> paymentMethods = ['Cash on Delivery', 'Khalti'];

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
  }

  void _handleSelection(String method) {
    setState(() {
      _selectedMethod = method;
    });
    Navigator.pop(context, method);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            ...paymentMethods.map((method) {
              final isSelected = _selectedMethod == method;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  color:
                      isSelected ? Colors.black.withOpacity(0.1) : Colors.white,
                  child: ListTile(
                    title: Text(
                      method,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey.shade800,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : null,
                    onTap: () => _handleSelection(method),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              _selectedMethod != null
                  ? () => Navigator.pop(context, _selectedMethod)
                  : null,
          child: const Text(
            'Confirm Payment Method',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
