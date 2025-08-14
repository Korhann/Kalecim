import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/searchpage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: GetUserData()
    );
  }
}
