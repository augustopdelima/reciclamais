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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAEFF9E), Color(0xFF8CFB38), Color(0xFF0EC904)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔹 Cabeçalho + banner
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Detalhes do Cupom',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CouponBanner(percentage: coupon.valorDesconto.toInt()),
                  ],
                ),

                // 🔹 Card com botão passado como parâmetro
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: CouponInfoCard(
                    coupon: coupon,
                    child: RedeemButton(
                      pointsRequired: 100,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cupom resgatado com sucesso!'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
