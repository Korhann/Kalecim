import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kiralik_kaleci/approvedfield.dart';
import 'package:kiralik_kaleci/football_field.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/loginpage.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/paymentpage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'appointmentspage.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';


const String currentFlavor = String.fromEnvironment('FLAVOR');

Future<void> initializeApp() async {
  if (kDebugMode) {
    print('Initializing app with FLAVOR: $currentFlavor');
  }
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // hive football fields
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('football_fields');
  Hive.registerAdapter(FootballFieldAdapter());
  await Hive.deleteBoxFromDisk('approved_fields');
  Hive.registerAdapter(ApprovedFieldAdapter());

  // onesignal push notifier
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("de08ba6c-7f05-4304-90ac-a3c3c1f6b94d");
  await PushHelper.updateOneSignal();

  addKeepersToOneSignal();

  // firebase crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    FirebaseCrashlytics.instance.setUserIdentifier(FirebaseAuth.instance.currentUser?.uid ?? 'anonymous');
  };

  //Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  OneSignal.Notifications.requestPermission(true);

  setupNotificationListener();
  String? userType = await getUserType();
  runApp(MyApp(userType: userType));
}

Future<String?> getUserType() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userType'); // Retrieve user type
} 

void addKeepersToOneSignal() async{
  final user = await FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance
    .collection('Users')
    .doc(user.uid)
    .get();

if (userDoc.exists && userDoc.data()?['sellerDetails'] != null) {
  await OneSignal.User.addTagWithKey('isKeeper', 'true');
} else {
  await OneSignal.User.addTagWithKey('isKeeper', 'false');
}
  }
}

class UpgradePrompt extends StatelessWidget {
  const UpgradePrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UpgradeAlert(
    dialogStyle: UpgradeDialogStyle.cupertino,
    child: Center(child: Text('Checking...')),
  ),
    );
  }
}


class MyApp extends StatelessWidget {
  final String? userType;
  const MyApp({super.key, required this.userType});
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Kalecim',
      initialRoute: '/',
      home: HomeRouter(),
    );
  }
}

class HomeRouter extends StatefulWidget {
  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
    checkForceUpdate(context);
  }

  Future<void> checkForceUpdate(BuildContext context) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(seconds: 10),
  minimumFetchInterval: const Duration(seconds: 0), // Always fetch latest for testing
));
  await remoteConfig.fetchAndActivate();

  final requiredVersion = remoteConfig.getString('appversion'); // Remote Config variable
  final info = await PackageInfo.fromPlatform();
  final currentVersion = info.version;
  print(currentVersion);
  print(requiredVersion);

  if (requiredVersion.isNotEmpty && currentVersion != requiredVersion) {
    if (context.mounted) {
      Showalert(context: context, text: 'En iyi özelliklerden faydalanmak için lütfen güncelleme yapın').showUpgradeAlert();
    }
  }
}


  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userType == null) {
      return LogIn();
    } else if (userType == 'seller') {
      return SellerMainPage(index: 2);
    } else if (userType == 'user') {
      return MainPage(index: 2);
    } else {
      return LogIn();
    }
  }
}

void setupNotificationListener() {
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    String? page = data?['page'];


    if (page != null) {
      BuildContext? context = MyApp.navigatorKey.currentContext;
      if (context != null) {
        switch (page) {
          case "payment":
            if (ModalRoute.of(context)?.settings.name != "/paymentPage") {
              String sellerUid = data?['sellerUid'] ?? '';
              String buyerUid = data?['buyerUid'] ?? '';
              String selectedDay = data?['selectedDay'] ?? '';
              String selectedHour = data?['selectedHour'] ?? '';
              String selectedField = data?['selectedField'] ?? '';
              String sellerDocId = data?['sellerDocId'] ?? '';
              String buyerDocId = data?['buyerDocId'] ?? '';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(
                    sellerUid: sellerUid,
                    buyerUid: buyerUid,
                    selectedDay: selectedDay,
                    selectedHour: selectedHour,
                    selectedField: selectedField,
                    sellerDocId: sellerDocId,
                    buyerDocId: buyerDocId,
                  ),
                ),
              );
            }
            break;
          case "appointment":
            if (ModalRoute.of(context)?.settings.name != "/appointmentsPage") {
              print('in this page rn');
              // alıcı sayfasında çağırınca alıcı olarak algılıyor
              userorseller = true;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentsPage(whereFrom: 'fromNoti')
                )
              );
            }
            break;
          default:
            print("Unknown page: $page");
            break;
        }
      }
    }
  });
}


