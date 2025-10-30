import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cupon.dart';
import '../viewmodel/cupon.dart';
import '../viewmodel/user.dart'; // Importado para verificar os pontos
import '../components/cupon_banner.dart';
import '../components/redeem_button.dart';

class CouponDetailScreen extends StatelessWidget {
  final Coupon coupon;

  const CouponDetailScreen({super.key, required this.coupon});

  // 💡 Cor principal: Verde Reciclagem (baseada no gradiente original)
  static const Color primaryGreen = Color(0xFF4CAF50); // Verde vibrante
  static const Color lightBackground = Color(0xFFF4F6F5); // Fundo off-white

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? primaryGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _redeemCoupon(
    BuildContext context,
    CouponViewModel couponVM,
    String? userId,
  ) async {
    if (userId == null) {
      _showSnackbar(
        context,
        'Você precisa estar logado para resgatar um cupom.',
      );
      return;
    }

    final userVM = context.read<UserViewModel>();
    if (userVM.userPoints < coupon.costPoints) {
      _showSnackbar(
        context,
        '❌ Pontos insuficientes! Você precisa de ${coupon.costPoints} pontos.',
        success: false,
      );
      return;
    }

    final success = await couponVM.redeemCoupon(
      couponId: coupon.id,
      userId: userId,
      cost: coupon.costPoints,
    );

    if (!context.mounted) return;

    if (success) {
      _showSnackbar(context, '🎉 Cupom resgatado com sucesso!', success: true);

      Navigator.pop(context);
    } else {
      _showSnackbar(
        context,
        '❌ Erro ao resgatar o cupom. Tente novamente.',
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o UserViewModel para obter os pontos atuais para o botão
    final userVM = context.watch<UserViewModel>();
    final couponVM = context.read<CouponViewModel>();

    // Obter o ID do usuário (pode ser null se não estiver logado)
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    // Calcula se o usuário tem pontos
    final canRedeem = userVM.userPoints >= coupon.costPoints;

    return Scaffold(
      backgroundColor: lightBackground,

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: lightBackground,
            elevation: 0,
            floating: true,
            pinned: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Detalhes do Cupom',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  CouponBanner(percentage: coupon.valorDesconto.toInt()),

                  const SizedBox(height: 30),

                  _buildDetailCard(context, coupon),

                  const SizedBox(height: 30),

                  RedeemButton(
                    pointsRequired: coupon.costPoints,
                    isEnabled:
                        canRedeem &&
                        (userId !=
                            null), // Ativo SÓ se tiver pontos E estiver logado
                    onPressed: () => _redeemCoupon(context, couponVM, userId),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de Detalhes, com foco na elevação e layout limpo
  Widget _buildDetailCard(BuildContext context, Coupon coupon) {
    return Card(
      elevation: 8, // Sombra para dar profundidade
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título Impactante (Valor do Desconto)
            Text(
              '${coupon.valorDesconto.toInt()}% DE DESCONTO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: primaryGreen,
                letterSpacing: 0.5,
              ),
            ),

            const Divider(height: 25, thickness: 1, color: Colors.grey),

            // Descrição (Mais detalhada)
            const Text(
              'Detalhes da Oferta:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              coupon.descricao,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // Informações Adicionais em linhas
            _buildInfoRow('ID do Cupom', coupon.id, Icons.credit_card),
            _buildInfoRow(
              'Validade da Compra',
              'Até R\$${coupon.maxPurchaseValue.toStringAsFixed(2)}',
              Icons.shopping_bag,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
