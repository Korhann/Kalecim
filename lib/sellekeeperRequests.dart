import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class seeUsersKeeperRequests extends StatefulWidget {
  const seeUsersKeeperRequests({super.key});

  @override
  State<seeUsersKeeperRequests> createState() => _seeUsersKeeperRequestsState();
}

class _seeUsersKeeperRequestsState extends State<seeUsersKeeperRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: GlobalStyles.textStyle(
            text: 'Kaleci Talepleri',
            context: context,
            size: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: sellerbackground,
        centerTitle: true,
      ),
      backgroundColor: sellerbackground,
    );
  }
}