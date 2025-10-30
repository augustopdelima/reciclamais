import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cupon.dart';
import '../viewmodel/cupon.dart';
import '../viewmodel/user.dart';
import '../components/cupon_info_card.dart';
import '../screens/user_cupon_detail.dart';

class UserPurchasedCouponsPage extends StatefulWidget {
  const UserPurchasedCouponsPage({super.key});

  @override
  State<UserPurchasedCouponsPage> createState() =>
      _UserPurchasedCouponsPageState();
}

class _UserPurchasedCouponsPageState extends State<UserPurchasedCouponsPage> {
  late TextEditingController _searchController;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Carregar cupons do usuário logado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userVM = context.read<UserViewModel>();
      final userId = userVM.currentUserId;
      if (userId != null) {
        context.read<CouponViewModel>().loadUserCoupons(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Coupon> _filterPurchasedCoupons(List<Coupon> coupons, String? userId) {
    if (userId == null) return [];
    final purchased = coupons.where((c) => c.assignedTo == userId).toList();
    if (_searchText.isEmpty) return purchased;

    final s = _searchText.toLowerCase();
    return purchased.where((c) {
      final descricao = c.descricao.toLowerCase();
      final id = c.id.toLowerCase();
      return descricao.contains(s) || id.contains(s);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final userId = userVM.currentUserId;

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          // Tela inicial
          Navigator.pushNamed(context, '/home');
          break;
        case 1:
          // Tela de cupons
          Navigator.pushNamed(context, '/user-cupons');
          break;
        case 2:
          // Perfil do usuário
          Navigator.pushNamed(context, '/profile');
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Cupons')),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF4CAF50),
        onTap: onItemTapped,
        currentIndex: 1,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por ID ou descrição',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchText = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() => _searchText = value),
              ),
            ),

            // Lista de cupons comprados
            Expanded(
              child: Consumer<CouponViewModel>(
                builder: (context, vm, child) {
                  final filtered = _filterPurchasedCoupons(
                    vm.userCoupons,
                    userId,
                  );

                  if (!vm.hasLoadedInitialCoupons) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Nenhum cupom comprado.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (userId != null) {
                        await vm.loadUserCoupons(userId);
                      }
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final cupon = filtered[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CouponDetailScreen(coupon: cupon),
                              ),
                            );
                          },
                          child: CouponInfoCard(coupon: cupon),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
