import 'package:flutter/material.dart';

class CustomBottomBarAdmin extends StatelessWidget {
  final int currentIndex;

  const CustomBottomBarAdmin({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    void onItemTapped(int index) {
      if (index == currentIndex) return;

      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/admin');
          break;

        case 1:
          Navigator.pushNamed(context, '/admin-cupons');
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
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer_outlined),
          activeIcon: Icon(Icons.local_offer),
          label: 'Cupons',
        ),
      ],
    );
  }
}
