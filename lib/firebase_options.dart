// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgcWDPD0RL8qMdGobrvmsCBLKTRRxZpO0',
    appId: '1:1042800475058:android:db4a22857acfca311982ab',
    messagingSenderId: '1042800475058',
    projectId: 'remisseaqp-dfd32',
    databaseURL: 'https://remisseaqp-dfd32-default-rtdb.firebaseio.com',
    storageBucket: 'remisseaqp-dfd32.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOCWqDpzdJbCgBYRc1MBf5gLWIuA0Wyng',
    appId: '1:1042800475058:ios:9307332eec5b8c7a1982ab',
    messagingSenderId: '1042800475058',
    projectId: 'remisseaqp-dfd32',
    databaseURL: 'https://remisseaqp-dfd32-default-rtdb.firebaseio.com',
    storageBucket: 'remisseaqp-dfd32.appspot.com',
    iosBundleId: 'com.jamir.remisseaqpdriver',
  );
}