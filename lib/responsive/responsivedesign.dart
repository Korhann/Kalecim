import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveDesign {
  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return DeviceType.desktop;
    } else if (width >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}