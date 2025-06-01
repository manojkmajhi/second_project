import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/database/shared_preferences.dart';
import 'package:second_project/pages/bottomnav.dart';
import 'package:second_project/pages/select_payment_method_page.dart';

class AddAddressInfo extends StatefulWidget {
  const AddAddressInfo({super.key});

  @override
  State<AddAddressInfo> createState() => _AddAddressInfoState();
}

class _AddAddressInfoState extends State<AddAddressInfo> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String? selectedPaymentMethod;
  List<Map<String, dynamic>> products = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List) {
      products = args.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showPaymentDialog();
    }
  }

  void _showLoaderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Colors.white,
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(width: 16),
            Text("Processing...", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Order Confirmed',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'Your order has been placed successfully and confirmation email sent!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const BottomNav(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Go To Home',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  double getTotalPrice() {
    return products.fold(0, (sum, product) {
      double price = double.tryParse(product['product_price'].toString()) ?? 0.0;
      int qty = product['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }

  String generateProductDetails() {
    String details = "";
    for (var i = 0; i < products.length; i++) {
      final p = products[i];
      final name = p['product_name'];
      final price = double.tryParse(p['product_price'].toString()) ?? 0.0;
      final quantity = p['quantity'] ?? 1;
      final subtotal = price * quantity;

      details +=
          "${i + 1}. $name\n   Price: Nrs.${price.toStringAsFixed(2)} x $quantity = Nrs.${subtotal.toStringAsFixed(2)}\n";
    }

    details += "\nTotal: Nrs.${getTotalPrice().toStringAsFixed(2)}";
    return details;
  }

  Future<void> _processOrder() async {
    _showLoaderDialog();

    try {
      final userIdStr = await SharedPreferenceHelper().getUserId();
      if (userIdStr == null) throw Exception("User not logged in");
      final userId = int.parse(userIdStr);

      final totalPrice = getTotalPrice();
      final productsJson = jsonEncode(products);
      
      // Insert order into database
      await DBHelper.instance.insertOrder(
        userId: userId,
        totalPrice: totalPrice,
        productsJson: productsJson,
        deliveryAddress: addressController.text.trim(),
        paymentMethod: selectedPaymentMethod ?? 'Unknown',
        customerName: nameController.text.trim(),
        customerEmail: emailController.text.trim(),
        customerPhone: phoneController.text.trim(),
      );

      // Clear cart after successful order
      await DBHelper.instance.clearCart();

      // Send confirmation email
      await _sendEmail();

      if (mounted) {
        Navigator.pop(context); // Close loader
        _showConfirmationDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    const username = 'manojmajhi77777@gmail.com';
    const password = 'lmof ckza lblt caft';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Your Store')
      ..recipients.add(emailController.text.trim())
      ..subject = 'Order Confirmation'
      ..text = '''
Hello ${nameController.text},

Thank you for your order!

Here are your delivery and order details:

Name: ${nameController.text}
Email: ${emailController.text}
Phone: ${phoneController.text}
Address: ${addressController.text}
Payment Method: $selectedPaymentMethod

Product Details:
${generateProductDetails()}

Your order has been placed successfully.

Regards,
Your Toolkit Nepal
''';

    try {
      await send(message, smtpServer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Payment Method',
            style: TextStyle(color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _paymentOptionTile(setState, 'Cash on Delivery'),
              _paymentOptionTile(setState, 'Khalti'),
              if (selectedPaymentMethod == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Please select a payment method',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (selectedPaymentMethod != null) {
                  Navigator.pop(context);
                  if (selectedPaymentMethod == 'Khalti') {
                    _startKhaltiPayment();
                  } else {
                    _processOrder();
                  }
                } else {
                  setState(() {});
                }
              },
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptionTile(StateSetter setState, String method) {
    return RadioListTile<String>(
      value: method,
      groupValue: selectedPaymentMethod,
      activeColor: Colors.black,
      title: Text(method, style: const TextStyle(color: Colors.black)),
      onChanged: (value) {
        setState(() {
          selectedPaymentMethod = value!;
        });
      },
    );
  }

  void _startKhaltiPayment() {
    final totalAmount = (getTotalPrice() * 100).toInt(); // Khalti uses paisa

    KhaltiScope.of(context).pay(
      config: PaymentConfig(
        amount: totalAmount,
        productIdentity: 'p1',
        productName: 'Order Payment',
        mobile: phoneController.text,
      ),
      preferences: [PaymentPreference.khalti],
      onSuccess: (success) {
        // Payment successful, process order
        _processOrder();
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Failed"),
            backgroundColor: Colors.red,
          ),
        );
      },
      onCancel: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Cancelled"),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        title: const Text('Add Delivery Address'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                nameController,
                "Full Name",
                Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full Name is required';
                  }
                  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                    return 'Name can only contain letters and spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildTextField(
                emailController,
                "Email",
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!RegExp(
                    r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  if (!value.endsWith('@gmail.com')) {
                    return 'Only Gmail addresses are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildTextField(
                phoneController,
                "Phone Number",
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone Number is required';
                  }
                  if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
                    return 'Phone Number must be exactly 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildTextField(
                addressController,
                "Full Address",
                Icons.home_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final selectedMethod = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelectPaymentMethodPage(
                            selectedMethod: selectedPaymentMethod,
                          ),
                        ),
                      );

                      if (selectedMethod != null) {
                        setState(() {
                          selectedPaymentMethod = selectedMethod;
                        });

                        if (selectedMethod == 'Cash on Delivery') {
                          _processOrder();
                          
                        } else if (selectedMethod == 'Khalti') {
                          _startKhaltiPayment();
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Continue to Payment",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}