import 'package:flutter/material.dart';
import '../models/cupon.dart';

class CouponInfoCard extends StatelessWidget {
  final Coupon coupon;

  const CouponInfoCard({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CUPOM ${coupon.valorDesconto.toInt()}% DE DESCONTO',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              coupon.descricao,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
