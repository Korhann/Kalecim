import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserType(String userType) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userType', userType); // Save user type
}
