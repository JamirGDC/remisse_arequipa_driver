import 'package:flutter/material.dart';

class ButtonMain extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonMain({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Satoshi',
              ),
              backgroundColor: const Color(0xFF835DF1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(text),
          ),
        );

  }
}
