import 'package:flutter/material.dart';
import '../models/cupon.dart';

class CouponInfoCard extends StatelessWidget {
  final Coupon coupon;
  final Widget? child;

  const CouponInfoCard({super.key, required this.coupon, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CUPOM ${coupon.valorDesconto.toInt()}% DE DESCONTO',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              coupon.descricao,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),

            if (child != null) child!, // botão vem aqui 👇
          ],
        ),
      ),
    );
  }
}
