import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvy0u-ECfL37K21-jTJjZxwzTSQS_3C_I',
    appId: '1:941589217621:web:84e9a27cede13d8341afdc',
    messagingSenderId: '941589217621',
    projectId: 'toolkitnepal-76278',
    authDomain: 'toolkitnepal-76278.firebaseapp.com',
    storageBucket: 'toolkitnepal-76278.firebasestorage.app',
    measurementId: 'G-8VHDVPS2YD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCx5OUnXEsXTsQ2FA-Prv4W8JkdCTKPkcU',
    appId: '1:941589217621:android:75298606f9d0f95d41afdc',
    messagingSenderId: '941589217621',
    projectId: 'toolkitnepal-76278',
    storageBucket: 'toolkitnepal-76278.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDCuEk-_NipMeRAsGgO8NK0lqvZCMkU9S0',
    appId: '1:941589217621:ios:d91a26decb8a06e141afdc',
    messagingSenderId: '941589217621',
    projectId: 'toolkitnepal-76278',
    storageBucket: 'toolkitnepal-76278.firebasestorage.app',
    iosBundleId: 'com.example.secondProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDCuEk-_NipMeRAsGgO8NK0lqvZCMkU9S0',
    appId: '1:941589217621:ios:d91a26decb8a06e141afdc',
    messagingSenderId: '941589217621',
    projectId: 'toolkitnepal-76278',
    storageBucket: 'toolkitnepal-76278.firebasestorage.app',
    iosBundleId: 'com.example.secondProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCvy0u-ECfL37K21-jTJjZxwzTSQS_3C_I',
    appId: '1:941589217621:web:c0cdacc08d8b70fd41afdc',
    messagingSenderId: '941589217621',
    projectId: 'toolkitnepal-76278',
    authDomain: 'toolkitnepal-76278.firebaseapp.com',
    storageBucket: 'toolkitnepal-76278.firebasestorage.app',
    measurementId: 'G-0GXEFQJXW0',
  );
}
