import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reciclamais/components/empty_state.dart';
import 'package:reciclamais/screens/cupon_detail.dart';
import '../viewmodel/cupon.dart';
import '../viewmodel/user.dart';
import '../components/cupon_card.dart'; // Certifique-se do caminho correto

class CouponGrid extends StatefulWidget {
  const CouponGrid({super.key});

  @override
  State<CouponGrid> createState() => _CouponGridState();
}

class _CouponGridState extends State<CouponGrid> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = context.read<UserViewModel>();
      final couponViewModel = context.read<CouponViewModel>();

      final userId = userViewModel.currentUserId;

      if (userId != null) {
        couponViewModel.loadAvailableCoupons();
        couponViewModel.loadUserCoupons(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CouponViewModel, UserViewModel>(
      builder: (context, couponVM, userVM, _) {
        final availableCoupons = couponVM.availableCoupons;
        final userId = userVM.currentUserId;

        if (availableCoupons.isEmpty &&
            userId != null &&
            !couponVM.hasLoadedInitialCoupons) {
          return const Center(child: CircularProgressIndicator());
        }

        if (availableCoupons.isEmpty) {
          // 💡 Novo widget de estado vazio
          return const EmptyStateWidget(
            icon: Icons.card_giftcard,
            message: 'Nenhum cupom disponível no momento. Volte mais tarde!',
          );
        }

        return GridView.builder(
          physics:
              const NeverScrollableScrollPhysics(), // Mantém a rolagem da SingleChildScrollView da HomeScreen
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8, // Ajuste para melhor visualização do card
            mainAxisSpacing: 16, // Mais espaçamento
            crossAxisSpacing: 16, // Mais espaçamento
          ),
          itemCount: availableCoupons.length,
          itemBuilder: (context, index) {
            final coupon = availableCoupons[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CouponDetailScreen(coupon: coupon),
                  ),
                );
              },
              // 💡 CouponCard estilizado com os novos dados
              child: CouponCard(
                percentage: coupon.valorDesconto.toInt(),
                requiredPoints: coupon.costPoints,
                description: coupon.descricao,
                // onRedeem agora está na CouponDetailScreen
                // Adicione a descrição para o card
              ),
            );
          },
        );
      },
    );
  }
}
