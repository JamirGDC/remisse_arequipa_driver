import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class InputMain extends StatelessWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isPassword;
  final bool isFocused;

  const InputMain({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    required this.focusNode,
    this.isPassword = false,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 0.5.h),
        Container(
          margin: EdgeInsets.symmetric(vertical: 0.8.h),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: .3.h),
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : const Color(0xFFF1F0F5),
            border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (isFocused)
                BoxShadow(
                  color: const Color(0xFF835DF1).withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 2.0,
                ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword,
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey), 
              suffixIcon: isPassword
                  ? const Icon(
                      Icons.visibility_off_outlined,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
