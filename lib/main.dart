import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:second_project/pages/home/home.dart';
import 'package:second_project/services/init_service.dart';
import 'package:second_project/pages/authentication/signin/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await InitService.initializeApp();
  final User? user = FirebaseAuth.instance.currentUser;

  runApp(
    KhaltiScope(
      publicKey: 'a4958b930c774e48ae1e1a5431ff303a',
      builder: (context, navKey) {
        return MyApp(navigatorKey: navKey, initialUser: user);
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final User? initialUser;

  const MyApp({super.key, required this.navigatorKey, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: initialUser != null ? const Home() : const SignIn(),
      localizationsDelegates: const [KhaltiLocalizations.delegate],
    );
  }
}
