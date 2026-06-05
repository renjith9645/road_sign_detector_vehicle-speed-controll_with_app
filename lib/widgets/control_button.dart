import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ControlButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      height: 85,
      child: ElevatedButton(onPressed: onPressed, child: Icon(icon, size: 40)),
    );
  }
}
