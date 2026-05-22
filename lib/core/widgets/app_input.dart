import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: const InputDecoration().copyWith(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        floatingLabelStyle: const TextStyle(color: Colors.black),
      ),
    );
  }
}
