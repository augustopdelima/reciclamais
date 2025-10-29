import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String name;
  final int points;
  final VoidCallback onLogout;

  const GreetingHeader({
    super.key,
    required this.name,
    required this.points,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFA0E586),
              radius: 18,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'Olá, $name',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              '$points',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 4),
            const Text('pontos', style: TextStyle(color: Colors.grey)),
            TextButton(onPressed: onLogout, child: const Text("Sair")),
          ],
        ),
      ],
    );
  }
}
