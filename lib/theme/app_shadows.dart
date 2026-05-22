import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1F0F172A),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];
}
