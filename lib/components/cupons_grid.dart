import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cupon.dart';
import '../services/cupon_service.dart';
import './cupon_card.dart';

class CouponGrid extends StatefulWidget {
  const CouponGrid({super.key});

  @override
  State<CouponGrid> createState() => _CouponGridState();
}

class _CouponGridState extends State<CouponGrid> {
  final _couponService = CouponService();
  List<Coupon> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final coupons = await _couponService.getAvailableCoupons();
      setState(() {
        _coupons = coupons;
      });
    } catch (e) {
      debugPrint('Erro ao carregar cupons: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_coupons.isEmpty) {
      return const Center(child: Text('Nenhum cupom disponível no momento.'));
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _coupons.length,
      itemBuilder: (context, index) {
        final coupon = _coupons[index];
        return CouponCard(
          percentage: coupon.valorDesconto.toInt(),
          requiredPoints: 100, // você pode adaptar depois
          onRedeem: () {
            // Aqui você chamaria a função para marcar como usado
          },
        );
      },
    );
  }
}
