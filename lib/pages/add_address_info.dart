import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:second_project/pages/home.dart';

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
  final cityController = TextEditingController();
  final stateController = TextEditingController();

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showPaymentDialog();
    }
  }

  void _showLoaderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
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
      builder:
          (_) => AlertDialog(
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
                    MaterialPageRoute(builder: (_) => const Home()),
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
      double price =
          double.tryParse(product['product_price'].toString()) ?? 0.0;
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

  void _sendEmail() async {
    _showLoaderDialog();

    String username = 'manojmajhi77777@gmail.com';
    String password = 'lmof ckza lblt caft';

    final smtpServer = gmail(username, password);

    final message =
        Message()
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
Address: ${addressController.text}, ${cityController.text}, ${stateController.text}
Payment Method: $selectedPaymentMethod

Product Details:
${generateProductDetails()}

Your order has been placed successfully.

Regards,
Your Toolkit Nepal
''';

    try {
      await send(message, smtpServer);
      Navigator.pop(context); // Close loader
      _showConfirmationDialog();
    } catch (e) {
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
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
                      _paymentOptionTile(setState, 'IME Pay'),
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
                          _sendEmail();
                        } else {
                          setState(() {}); // Refresh UI to show error
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
              ),
              const SizedBox(height: 15),
              _buildTextField(
                emailController,
                "Email",
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                phoneController,
                "Phone Number",
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                addressController,
                "Full Address",
                Icons.home_outlined,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                cityController,
                "City",
                Icons.location_city_outlined,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                stateController,
                "State/Province",
                Icons.map_outlined,
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Home()),
                          ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator:
          (value) => value == null || value.isEmpty ? 'Required field' : null,
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
