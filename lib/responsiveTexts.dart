import 'package:flutter/material.dart';

class ScaleSize {
  static double textScaleFactor(BuildContext context, {double maxTextScaleFactor = 1.4}) {
    final width = MediaQuery.of(context).size.width;
    double val = (width / 375) * 1; // 1 is the base scale
    return val.clamp(0.9, maxTextScaleFactor); // allows slight downscale if needed
  }
}
