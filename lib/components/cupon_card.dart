import 'package:flutter/material.dart';

class CouponCard extends StatelessWidget {
  final int percentage;
  final int requiredPoints;
  final String description;

  const CouponCard({
    super.key,
    required this.percentage,
    required this.requiredPoints,
    required this.description,
  });

  // Cor principal
  static const Color primaryGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Sombra para destaque
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: primaryGreen,
                height: 1, // Ajuste para não ter muito espaço vertical
              ),
            ),
            const Text(
              'De desconto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const Spacer(), // Espaçador para empurrar o texto para cima
            // 🔹 Descrição curta (ajustada para caber no card)
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2, // Limitar a 2 linhas
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const Spacer(), // Espaçador para empurrar os pontos para baixo
            // 🔹 Custo em Pontos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 18),
                const SizedBox(width: 5),
                Text(
                  '$requiredPoints pts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5), // Espaço extra abaixo dos pontos
          ],
        ),
      ),
    );
  }
}
