import 'package:flutter/material.dart';

class ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextStyle? textStyle; // Optional text style

  const ProfileActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Icon(icon, size: 30.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              title,
              style: textStyle ?? const TextStyle(), // Apply optional style
            ),
          ),
          const Icon(Icons.arrow_forward_ios_outlined),
        ],
      ),
    );
  }
}