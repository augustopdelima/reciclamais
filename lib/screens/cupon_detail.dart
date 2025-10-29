import 'package:flutter/material.dart';
import '../models/cupon.dart';
import '../components/cupon_banner.dart';
import '../components/cupon_info_card.dart';
import '../components/redeem_button.dart';

class CouponDetailScreen extends StatelessWidget {
  final Coupon coupon;

  const CouponDetailScreen({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resgate Cupom'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CouponBanner(percentage: coupon.valorDesconto.toInt()),
            const SizedBox(height: 20),
            CouponInfoCard(coupon: coupon),
            const SizedBox(height: 20),
            RedeemButton(
              pointsRequired: 100,
              onPressed: () {
                // Aqui você fará o resgate no Firebase
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cupom resgatado com sucesso!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
