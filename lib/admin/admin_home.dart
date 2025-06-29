import 'package:flutter/material.dart';
import 'package:second_project/admin/add_product.dart';
import 'package:second_project/admin/admin_reviews.dart';
import 'package:second_project/admin/admin_signin.dart';
import 'package:second_project/admin/admin_order.dart';
import 'package:second_project/admin/user_details.dart';
import 'package:second_project/admin/view_product.dart';
import 'package:second_project/admin/sales_report.dart'; // Add this import
import 'package:second_project/widget/support_widget.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 251, 251),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi, Admin", style: AppWidget.boldTextFieldStyle()),
                    Text(
                      "Welcome to ToolKit",
                      style: AppWidget.lightTextFieldStyle(),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset(
                    "assets/logo/user.png",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Buttons
            Expanded(
              child: ListView(
                children: [
                  _buildAdminButton(
                    label: "Add Product",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddProduct()),
                      );
                    },
                  ),
                  _buildAdminButton(
                    label: "View All Products",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewProduct(),
                        ),
                      );
                    },
                  ),
                  _buildAdminButton(
                    label: "Manage Orders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminOrdersScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAdminButton(
                    label: "View Users",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserDetailsPage(),
                        ),
                      );
                    },
                  ),
                  _buildAdminButton(
                    label: "Sales Report",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SalesReportScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAdminButton(
                    label: "Reviews",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminReviewsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAdminButton(
                    label: "Logout",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminSignin(),
                        ),
                      );
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton({
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}