/*

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/homepage.dart';
import 'package:kiralik_kaleci/messagepage.dart';
import 'package:kiralik_kaleci/profilepage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class Navpage extends StatefulWidget {
  const Navpage({Key? key}) : super(key: key);

  @override
  _NavpageState createState() => _NavpageState();
}

class _NavpageState extends State<Navpage> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [HomePage(), MessagePage(), ProfilePage()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings),
        title: ("Settings"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      // ... (other properties)
    );
  }
}
*/
