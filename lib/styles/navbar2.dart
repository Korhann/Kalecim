/*

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kiralik_kaleci/homepage.dart';
import 'package:kiralik_kaleci/messagepage.dart';
import 'package:kiralik_kaleci/profilepage.dart';

class Navbar2 extends StatefulWidget {
  const Navbar2({super.key});

  @override
  State<Navbar2> createState() => _Navbar2State();
}

class _Navbar2State extends State<Navbar2> {
  
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = [
    HomePage(),
    MessagePage(),
    ProfilePage()
  ];


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 15
          ),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.home, 
                text: "Ana Sayfa",
              ),
              GButton(
                icon: Icons.message,
                text: "Mesajlar",
              ),
              GButton(
                icon: Icons.person,
                text: "Profil",
              )
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index){
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
*/