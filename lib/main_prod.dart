import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/env.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.setEnvironment(EnvironmentType.prod);

  if (Env.useFirebase) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'KiralikKaleci',
        options: DefaultFirebaseOptions.currentPlatform,
    );
    }
  }

  await initializeApp();
  String? userType = await getUserType();

  runApp(MyApp(userType: userType));
}

Future<String?> getUserType() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userType'); // Retrieve user type
} 