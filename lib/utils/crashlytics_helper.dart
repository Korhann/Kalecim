import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

Future<void> reportErrorToCrashlytics(
  dynamic e,
  StackTrace stack, {
  String? reason,
  bool fatal = false,
}) async {
  if (!kIsWeb){
    await FirebaseCrashlytics.instance.recordError(
    e,
    stack,
    reason: reason,
    fatal: fatal,
  );
  }
}