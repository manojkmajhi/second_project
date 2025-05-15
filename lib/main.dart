import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:second_project/admin/add_product.dart';
import 'package:second_project/admin/admin_home.dart';
import 'package:second_project/firebase_options.dart';
import 'package:second_project/pages/add_address_info.dart';
import 'package:second_project/pages/bottomnav.dart';
import 'package:second_project/pages/category_products.dart';
import 'package:second_project/pages/checkout.dart';
import 'package:second_project/pages/home.dart';
import 'package:second_project/pages/signin.dart';
import 'package:second_project/data/local/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DBHelper.instance.getDB();
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
      home: SignIn(),
    );
  }
}
