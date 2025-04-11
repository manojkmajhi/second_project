import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:second_project/pages/bottomnav.dart';
import 'package:second_project/pages/signup.dart';
import 'package:second_project/widget/support_widget.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String? email = "", password = "";

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Logged In Successfully'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found for that email.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wrong password provided for that user.')),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logging in...')));
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
                    "SignIn to ToolKit Nepal",
                    style: AppWidget.boldTextFieldStyle(),
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: Text(
                    "Welcome! to ToolKit Nepal please enter login credentials to continue.",
                    textAlign: TextAlign.justify,
                    style: AppWidget.lightTextFieldStyle(),
                  ),
                ),

                SizedBox(height: 20.0),
                Text("Email", style: AppWidget.semiboldTextFieldStyle()),
                SizedBox(height: 20.0),

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
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}',
                      ).hasMatch(value)) {
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
                Text("Password", style: AppWidget.semiboldTextFieldStyle()),
                SizedBox(height: 20.0),

                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator:
                        (value) =>
                            value != null && value.length < 6
                                ? "Password must be at least 6 characters"
                                : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your password",
                    ),
                  ),
                ),

                SizedBox(height: 20.0),
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

                GestureDetector(
                  onTap: () {
                    setState(() {
                      email = emailController.text;
                      password = passwordController.text;
                      userLogin();
                    });
                    userLogin();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        "Login",
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
                      "Don't have an account? ",
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
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                      child: Text(
                        "Signup",
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
