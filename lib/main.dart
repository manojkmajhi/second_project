import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:second_project/admin/add_product.dart';
import 'package:second_project/admin/admin_home.dart';
import 'package:second_project/firebase_options.dart';
import 'package:second_project/pages/bottomnav.dart';
import 'package:second_project/pages/category_products.dart';
import 'package:second_project/pages/home.dart';
import 'package:second_project/pages/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AddProduct(),
    );
  }
}
