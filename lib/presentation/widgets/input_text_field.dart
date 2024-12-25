import 'dart:ffi';

import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Icon icon;

  const InputTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        prefixIcon: icon,
      ),
    );
  }
}
