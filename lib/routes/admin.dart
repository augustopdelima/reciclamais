import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reciclamais/components/admin_nav_bar.dart';
import 'package:reciclamais/viewmodel/user.dart';
import '../components/admin_credit_points.dart';
import '../components/user_list_card.dart';
import '../viewmodel/admin_user.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<AdminViewModel>(context, listen: false);
      vm.startListener();
    });
  }

  void _logout() async {
    Provider.of<UserViewModel>(context, listen: false).stopUserListener();

    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // volta para login
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home do Admin"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Sair",
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBarAdmin(currentIndex: 0),
      body: Column(
        children: [
          // Campo de pesquisa
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xffc4f7a1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              onChanged: vm.search,
              decoration: const InputDecoration(
                hintText: "Digite para pesquisar",
                border: InputBorder.none,
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Lista de usuários
          Expanded(
            child: vm.filteredUsers.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum usuário encontrado",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.filteredUsers.length,
                    itemBuilder: (_, index) {
                      final user = vm.filteredUsers[index];
                      return UserListTile(
                        user: user,
                        onSelect: () {
                          vm.selectUser(user);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AdminCreditPointsSheet(),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
