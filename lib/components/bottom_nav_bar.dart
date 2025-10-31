import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    void onItemTapped(int index) {
      if (index == currentIndex) return;

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

        case 3:
          Navigator.pushNamed(context, '/points');
          break;
      }
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => onItemTapped(index),
      selectedItemColor: Colors.green[700],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer_outlined),
          activeIcon: Icon(Icons.local_offer),
          label: 'Meus Cupons',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Pontos de Coleta',
        ),
      ],
    );
  }
}
