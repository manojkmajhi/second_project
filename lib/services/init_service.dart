import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:second_project/database/firebase_options.dart';
import 'package:second_project/database/data/local/db_helper.dart';

class InitService {
  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await DBHelper.instance.getDB();
  }
}
