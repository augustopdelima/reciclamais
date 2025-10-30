import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Adicione o pacote 'provider' ao seu pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reciclamais/components/banner.dart';
import 'package:reciclamais/components/cupons_grid.dart';
import 'package:reciclamais/components/greeting_header.dart';
import '../viewmodel/user.dart'; // Importe seu novo ViewModel

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserViewModel>(context, listen: false).startUserListener();
    });
  }

  void _logout() async {
    Provider.of<UserViewModel>(context, listen: false).stopUserListener();

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onItemTapped(int index) {
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

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    if (userViewModel.userData == null && userViewModel.currentUserId != null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userViewModel.currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: Text('Redirecionando...')));
    }

    final name = userViewModel.userName;
    final points = userViewModel.userPoints;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GreetingHeader agora usa os dados do ViewModel
              GreetingHeader(
                name: name,
                points: points,
                onLogout: () => _logout(),
              ),
              const SizedBox(height: 24),
              const FeaturedBanner(
                imageUrl:
                    'https://via.placeholder.com/600x300.png?text=Promoção+25%25+Desconto',
                onRedeem: null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Cupons',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const CouponGrid(),
            ],
          ),
        ),
      ),
      // ... BottomNavigationBar (mantido como está)
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF4CAF50),
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
