import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/env.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.setEnvironment(EnvironmentType.dev);

  if (Env.useFirebase) {
    if (Firebase.apps.isEmpty){
      await Firebase.initializeApp(
        name: 'KiralikKaleci-dev',
        options: DefaultFirebaseOptions.currentPlatform,
    );
    // debug modunda crash test etmek için
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  }

  await initializeApp();
  String? userType = await getUserType();

  // runApp(MyApp(userType: userType));
  runApp(MyApp(userType:userType));
}

Future<String?> getUserType() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userType'); // Retrieve user type
} 