import 'package:flutter/material.dart';

class SelectPaymentMethodPage extends StatefulWidget {
  final String? selectedMethod;

  const SelectPaymentMethodPage({super.key, this.selectedMethod});

  @override
  State<SelectPaymentMethodPage> createState() => _SelectPaymentMethodPageState();
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

    // Optionally pop with selected method immediately
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.pop(context, method);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: paymentMethods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final method = paymentMethods[index];
          final isSelected = _selectedMethod == method;

          return ListTile(
            tileColor: isSelected ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.black),
            ),
            title: Text(
              method,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _handleSelection(method),
          );
        },
      ),
    );
  }
}
