import 'package:flutter/material.dart';
import 'package:second_project/pages/signin.dart';
import 'package:second_project/widget/support_widget.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/logo/ToolKit_logo.png",
                    height: 190,
                    width: 190,
                  ),
                ),
                Center(
                  child: Text(
                    "Register to ToolKit Nepal",
                    style: AppWidget.boldTextFieldStyle(),
                  ),
                ),
                SizedBox(height: 30.0),

                // Full Name
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) =>
                        value!.isEmpty ? "Name cannot be empty" : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your Full Name",
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                // Email
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your email",
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                // Password
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) => value != null && value.length < 6
                        ? "Password must be at least 6 characters"
                        : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your password",
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                // Confirm Password
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Confirm your password",
                    ),
                  ),
                ),

                SizedBox(height: 50.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Submit Button
                GestureDetector(
                  onTap: _submitForm,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
