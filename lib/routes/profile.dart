import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/history.dart';
import '../viewmodel/history.dart';
import '../services/auth_service.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Nenhum usuário logado.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => UserProfileViewModel(currentUser.uid),
      child: _UserProfileBody(),
    );
  }
}

class _UserProfileBody extends StatelessWidget {
  const _UserProfileBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perfil do Usuário',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<UserProfileViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: UserProfileScreen.primaryColor,
              ),
            );
          }

          if (vm.user == null) {
            return const Center(
              child: Text(
                'Erro ao carregar dados do usuário.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _ProfileHeader(user: vm.user!),
                const SizedBox(height: 20),
                _PointsCard(points: vm.user!.points),
                const SizedBox(height: 30),
                _HistorySelector(
                  selectedType: vm.selectedHistoryType,
                  onSelect: vm.setSelectedHistoryType,
                ),
                const SizedBox(height: 20),
                _HistoryList(history: vm.currentHistoryList),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: UserProfileScreen.primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/coupons');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: UserProfileScreen.accentColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            size: 60,
            color: UserProfileScreen.primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          user.email,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  final int points;
  const _PointsCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UserProfileScreen.accentColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: UserProfileScreen.primaryColor.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: 1.0, // valor entre 0 e 1
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    UserProfileScreen.primaryColor,
                  ),
                  strokeWidth: 5,
                ),
              ),
              Text(
                points.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UserProfileScreen.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seus pontos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Troque seus pontos por cupons e descontos em supermercados, restaurantes e muito mais!',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySelector extends StatelessWidget {
  final HistoryType selectedType;
  final Function(HistoryType) onSelect;
  const _HistorySelector({required this.selectedType, required this.onSelect});

  String _titleFor(HistoryType t) {
    switch (t) {
      case HistoryType.redeemedCoupons:
        return 'Cupons Resgatados';
      case HistoryType.collectedPoints:
        return 'Coletas Realizadas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: UserProfileScreen.accentColor.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: HistoryType.values.map((t) {
          final isSelected = selectedType == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _titleFor(t),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? UserProfileScreen.primaryColor
                        : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<HistoryItem> history;
  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'Nenhum histórico encontrado.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return _HistoryListItem(item: item);
      },
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final HistoryItem item;

  const _HistoryListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    // Detecta automaticamente o tipo
    final bool isRedeem = item is RedeemHistoryItem;
    final String title = isRedeem ? 'Resgate de cupom' : 'Coleta de materiais';
    final IconData icon = isRedeem ? Icons.card_giftcard : Icons.recycling;
    final Color iconColor = isRedeem
        ? Colors.redAccent
        : UserProfileScreen.primaryColor;
    final int points = item.points;

    final DateTime date = item.date;
    final String dateText =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.detail,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateText,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 4),
              Text(
                '$points pts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
