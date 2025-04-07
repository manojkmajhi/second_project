import 'package:flutter/material.dart';
import 'package:second_project/widget/support_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 30.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: Container(
        margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                "assets/logo/user.png",
                height: 100,
                width: 100,
              ),
            ),
            Center(
              child: Text(
                "Welcome! to ToolKit Nepal please enter login credintials to continue",
                textAlign: TextAlign.justify,
                style: AppWidget.lightTextFieldStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
