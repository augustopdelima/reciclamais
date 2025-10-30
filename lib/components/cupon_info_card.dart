import 'package:flutter/material.dart';
import '../models/cupon.dart';

class CouponInfoCard extends StatelessWidget {
  final Coupon coupon;
  final Widget? child; // O child é o RedeemButton

  const CouponInfoCard({super.key, required this.coupon, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detalhes do Cupom:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              coupon.descricao,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            // O botão de resgate (child) ficaria aqui, se usado
            if (child != null) ...[
              const Divider(height: 30, thickness: 1),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
