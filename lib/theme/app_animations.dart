import 'package:flutter/material.dart';

abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve smooth = Curves.easeInOut;
}
