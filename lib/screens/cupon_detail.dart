import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reciclamais/components/bottom_nav_bar.dart';
import '../models/cupon.dart';
import '../viewmodel/cupon.dart';
import '../viewmodel/user.dart';
import '../components/cupon_banner.dart';
import '../components/redeem_button.dart';

class CouponDetailScreen extends StatelessWidget {
  final Coupon coupon;
  const CouponDetailScreen({super.key, required this.coupon});

  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightBackground = Color(0xFFF4F6F5);

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
    int costPoints,
  ) async {
    if (userId == null) {
      _showSnackbar(
        context,
        'Você precisa estar logado para resgatar um cupom.',
      );
      return;
    }

    final userVM = context.read<UserViewModel>();
    if (userVM.userPoints < costPoints) {
      _showSnackbar(
        context,
        '❌ Pontos insuficientes! Você precisa de $costPoints pontos.',
      );
      return;
    }

    final success = await couponVM.redeemCoupon(
      couponId: coupon.id,
      userId: userId,
      cost: costPoints,
    );

    if (!context.mounted) return;

    if (success) {
      _showSnackbar(context, '🎉 Cupom resgatado com sucesso!', success: true);
      Navigator.pop(context);
    } else {
      _showSnackbar(context, '❌ Erro ao resgatar o cupom. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final couponVM = context.read<CouponViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final canRedeem = userVM.userPoints >= coupon.costPoints;

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalhes do Cupom',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: CustomBottomBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            CouponBanner(percentage: coupon.valorDesconto.toInt()),
            const SizedBox(height: 30),
            _DetailCard(coupon: coupon),
            const SizedBox(height: 30),
            RedeemButton(
              pointsRequired: coupon.costPoints,
              isEnabled: canRedeem && (userId != null),
              onPressed: () =>
                  _redeemCoupon(context, couponVM, userId, coupon.costPoints),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Coupon coupon;
  const _DetailCard({required this.coupon});

  static const Color primaryGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${coupon.valorDesconto.toInt()}% DE DESCONTO',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: primaryGreen,
              ),
            ),
            const Divider(height: 25, thickness: 1, color: Colors.grey),
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
            _InfoRow(
              title: 'Validade da Compra',
              value: 'Até R\$${coupon.maxPurchaseValue.toStringAsFixed(2)}',
              icon: Icons.shopping_bag,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _InfoRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  static const Color primaryGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
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
