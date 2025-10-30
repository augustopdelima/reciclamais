import 'package:flutter/material.dart';

class CouponBanner extends StatelessWidget {
  final int percentage;

  const CouponBanner({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      // 💡 Efeito de Sombra sutil para destacar o banner
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        // Gradiente vibrante para alto impacto
        gradient: const LinearGradient(
          colors: [Color(0xFF8CFB38), Color(0xFF0EC904)], // Cores do seu tema
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MEGA DESCONTO',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            // 💡 Porcentagem em destaque, agora branca para alto contraste
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black45,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const Text(
              'DE DESCONTO EXCLUSIVO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
