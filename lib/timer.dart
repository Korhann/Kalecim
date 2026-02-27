import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TimerService with ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;

  TimerService._internal();

  Timer? _weeklyTimer;
  Timer? _countdownTimer;
  late Duration remainingTime;

  final StreamController<Duration> _remainingTimeController = StreamController<Duration>.broadcast();
  Stream<Duration> get remainingTimeStream => _remainingTimeController.stream;

  final String? currentuser = FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _weeklyTimer?.cancel();
    _countdownTimer?.cancel();
    _remainingTimeController.close();
    super.dispose();
  }

  // eğer gün pazartesi olmuşsa main.dart ta bakıp randevuları ve saatleri yeniliyor
  void startWeeklyRefresh() async {
    await performWeeklyReset(); 
    remainingTime = _calculateTimeUntilNextTargetDay();
    print('succesfull for the user $currentuser');
    _scheduleWeeklyRefresh();
    _startCountdown();
  
} 


  Future<void> performWeeklyReset() async {
    // Perform the refresh tasks
    refreshAppointments();
    // Schedule the next refresh
    _scheduleWeeklyRefresh();
    _startCountdown();
  }

  void _scheduleWeeklyRefresh() {
    print('2');
    Duration duration = _calculateTimeUntilNextTargetDay();
    _weeklyTimer = Timer(duration, () async {
      await performWeeklyReset();
    });
  }

  void _startCountdown() {
    print('3');
    // Start a countdown timer for the next refresh
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime = _calculateTimeUntilNextTargetDay();
      _remainingTimeController.add(remainingTime);
    });
  }

  /// Calculates the duration until the next target day and time (e.g., Tuesday at 00:00).
  Duration _calculateTimeUntilNextTargetDay() {
    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 3)); // Adjusting to UTC+3 for Turkey Time
    int targetDay = DateTime.monday;

    // Calculate days until the target day
    int daysUntilTarget = (targetDay - now.weekday + 7) % 7;

    // If today is the target day but time has passed the target hour, move to next week's target day
    DateTime targetDate = now.add(Duration(days: daysUntilTarget)).copyWith(hour: 0, minute: 0, second: 0);
    if (now.isAfter(targetDate)) {
      targetDate = targetDate.add(const Duration(days: 7));
    }

    return targetDate.difference(now);
  }

  // Refreshes appointments by resetting all 'istaken' fields to false.
  void refreshAppointments() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Users').doc(currentuser).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty && data.containsKey('sellerDetails')) {
        Map<String, dynamic> sellerDetails = data['sellerDetails'];
        if (sellerDetails.containsKey('selectedHoursByDay')) {
          Map<String, dynamic> selectedHoursByDay = sellerDetails['selectedHoursByDay'];
          // Set all 'istaken' fields to false
          selectedHoursByDay.forEach((days, values) {
            if (values is List) {
              for (var props in values) {
                if (props is Map<String, dynamic> && props.containsKey('istaken')) {
                  props['istaken'] = false;
                  print('correctomente');
                }
              }
            }
          });
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentuser)
              .update({'sellerDetails.selectedHoursByDay': selectedHoursByDay});
        }
      }
    }
    print("Appointments refreshed. Time now: ${DateTime.now().toUtc().add(const Duration(hours: 3))}");
  }
}
