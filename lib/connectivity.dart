import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late InternetConnectionChecker connectionChecker;
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    connectionChecker = InternetConnectionChecker.createInstance();
    _connectionSubscription = connectionChecker.onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          hasInternet = status == InternetConnectionStatus.connected;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    connectionChecker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show the child when there is internet, otherwise show offline screen
    return hasInternet
        ? widget.child
        : Scaffold(
            backgroundColor: userorseller ? sellerbackground : background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/icons/no-wifi.png',
                    color: userorseller ? Colors.white : Colors.black,
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Bağlantı Yok',
                    style: TextStyle(
                      color: userorseller ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lütfen bağlantınızı kontrol edin ve tekrar deneyin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: userorseller ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () async{
                      if (await InternetConnection().hasInternetAccess) {
                        hasInternet = true;
                      }
                    },
                    child: Text(
                      'Tekrar dene',
                      style: TextStyle(
                        color: Colors.black
                      ),
                    )
                  )
                ],
              ),
            ),
          );
  }
}
