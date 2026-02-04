import 'package:flutter/material.dart';

class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({required this.name, this.logo});
  final String name;
  final String? logo;

  @override
  Widget build(BuildContext context) {
    if (logo != null && logo!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(logo!),
        backgroundColor: const Color(0xFFEFF0FF),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFEFF0FF),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '•',
        style: const TextStyle(
          color: Color(0xFF6C5CE7),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
