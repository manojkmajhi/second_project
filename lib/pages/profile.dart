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
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 235, 235, 235),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
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
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(),
                ),
                height: 120,
                width: 120,
                child: ClipOval(
                  child: Image.asset(
                    "assets/logo/googleicon.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              width: MediaQuery.of(context).size.width,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 10.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_2_outlined, size: 30.0),
                        SizedBox(width: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name',
                              style: AppWidget.lightTextFieldStyle(),
                            ),
                            Text(
                              'Google Baba',
                              style: AppWidget.semiboldTextFieldStyle(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              width: MediaQuery.of(context).size.width,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 10.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined, size: 30.0),
                        SizedBox(width: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: AppWidget.lightTextFieldStyle(),
                            ),
                            Text(
                              'googlebaba@gmail.com',
                              style: AppWidget.semiboldTextFieldStyle(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.delete_outline, size: 30.0),
                        SizedBox(width: 10.0),
                        Text(
                          'Delete Account',
                          style: AppWidget.semiboldTextFieldStyle(),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_outlined),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.logout_outlined, size: 30.0),
                        SizedBox(width: 10.0),
                        Text(
                          'Logout',
                          style: AppWidget.semiboldTextFieldStyle(),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_outlined),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
