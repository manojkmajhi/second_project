import 'package:flutter/material.dart';
import 'package:second_project/pages/signin.dart';
import 'package:second_project/widget/support_widget.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
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

              Container(
                padding: EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your Full Name",
                  ),
                ),
              ),

              SizedBox(height: 20.0),

              Container(
                padding: EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your email or phone number",
                  ),
                ),
              ),

              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your password",
                  ),
                ),
              ),
              SizedBox(height: 20.0),

              Container(
                padding: EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(color: Color(0xFFF4F5F9)),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your password",
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
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      "SignIn",
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
    );
  }
}
