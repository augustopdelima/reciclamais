import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'home.dart';
import 'admin.dart';

class RootScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Loading inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = snapshot.data;
        if (firebaseUser == null) {
          userViewModel.stopUserListener();
          return LoginScreen();
        }

        // Inicia listener do usuário
        userViewModel.startUserListener();

        return Consumer<UserViewModel>(
          builder: (context, vm, _) {
            // Aguardando dados do usuário
            if (vm.userData == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // Redireciona conforme role
            return vm.userRole == 'admin'
                ? const AdminHomeScreen()
                : const HomeScreen();
          },
        );
      },
    );
  }
}
