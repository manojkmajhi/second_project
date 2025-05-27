import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:second_project/services/init_service.dart';
import 'package:second_project/pages/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitService.initializeApp();

  runApp(
    KhaltiScope(
      publicKey: 'a4958b930c774e48ae1e1a5431ff303a',
      builder: (context, navKey) {
        return MyApp(navigatorKey: navKey);
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const SignIn(),
      localizationsDelegates: const [KhaltiLocalizations.delegate],
    );
  }
}
