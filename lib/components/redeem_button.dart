import 'package:flutter/material.dart';

class RedeemButton extends StatelessWidget {
  final int pointsRequired;
  final VoidCallback onPressed;
  final bool isEnabled; // 💡 NOVO: Controla se o botão está ativo

  const RedeemButton({
    super.key,
    required this.pointsRequired,
    required this.onPressed,
    this.isEnabled = true, // Padrão: ativo
  });

  // Cor principal
  static const Color primaryGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    // Define a cor do botão com base no estado
    final buttonColor = isEnabled ? primaryGreen : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 💡 Texto do Custo em Pontos
          Row(
            children: [
              const Icon(
                Icons.star, // Ícone de ponto/moeda
                color: primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '$pointsRequired pontos',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // 💡 Botão de Ação
          ElevatedButton(
            // Usa onPressed apenas se estiver ativo, senão passa null
            onPressed: isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              // Desabilitar a sombra no estado desabilitado
              elevation: isEnabled ? 8 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(
              isEnabled ? 'Trocar Pontos' : 'Pontos Insuficientes',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
