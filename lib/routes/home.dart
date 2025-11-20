import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Adicione o pacote 'provider' ao seu pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reciclamais/components/banner.dart';
import 'package:reciclamais/components/bottom_nav_bar.dart';
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
    final uservm = Provider.of<UserViewModel>(context, listen: false);

    await uservm.logout();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
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
                    'https://img.freepik.com/vetores-gratis/modelo-de-cupom-moderno-com-design-plano_23-2147964693.jpg',
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
      bottomNavigationBar: CustomBottomBar(currentIndex: 0),
    );
  }
}
