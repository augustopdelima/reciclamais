import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reciclamais/components/admin_nav_bar.dart';
import '../viewmodel/admin_cupon.dart';
import '../models/cupon.dart';

class AdminCouponsPage extends StatelessWidget {
  AdminCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminCouponsViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Gerenciar Cupons")),
        bottomNavigationBar: CustomBottomBarAdmin(currentIndex: 1),
        body: Consumer<AdminCouponsViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _SearchBar(vm: vm),
                ),
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.coupons.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum cupom encontrado para sua pesquisa",
                          ),
                        )
                      : ListView.builder(
                          itemCount: vm.coupons.length,
                          itemBuilder: (context, index) {
                            final cupom = vm.coupons[index];
                            final user = cupom.assignedTo != null
                                ? vm.getUserForCoupon(cupom.assignedTo!)
                                : null;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(cupom.descricao),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Pontos: ${cupom.costPoints}"),
                                    Text("ID do Cupom: ${cupom.id}"),
                                    Text(
                                      "Resgatado em: ${cupom.redeemed ? 'Sim' : 'Não'}",
                                    ),
                                    if (user != null)
                                      Text(
                                        "Comprado por: ${user.name} (${user.email})",
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                                  onPressed: () => _showBottomConfirmation(
                                    context,
                                    cupom,
                                    vm,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showBottomConfirmation(
    BuildContext context,
    Coupon cupom,
    AdminCouponsViewModel vm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.7,
        builder: (_, controller) {
          final user = cupom.assignedTo != null
              ? vm.getUserForCoupon(cupom.assignedTo!)
              : null;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue.shade400,
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Detalhes do Cupom",
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  "Descrição: ${cupom.descricao}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text("Pontos: ${cupom.costPoints}"),
                Text("ID do Cupom: ${cupom.id}"),
                Text("Resgatado: ${cupom.redeemed ? 'Sim' : 'Não'}"),
                if (user != null)
                  Text("Comprado por: ${user.name} (${user.email})"),
                if (cupom.createdAt != null)
                  Text("Criado em: ${cupom.createdAt}"),
                if (cupom.spentByAdmin != null)
                  Text(
                    "Marcado por admin: ${cupom.spentByAdmin ?? false ? 'Sim' : 'Não'}",
                  ),
                if (cupom.spentAt != null) Text("Data gasto: ${cupom.spentAt}"),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      child: const Text("Marcar como gasto"),
                      onPressed: () async {
                        Navigator.pop(context);
                        final adminId = FirebaseAuth.instance.currentUser!.uid;
                        final success = await vm.markAsSpent(cupom.id, adminId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? "Cupom marcado como gasto"
                                  : "Erro ao marcar cupom",
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Componente do SearchBar com debounce
class _SearchBar extends StatefulWidget {
  final AdminCouponsViewModel vm;

  const _SearchBar({required this.vm});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.vm.updateSearch(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: "Buscar cupons por descrição, usuário, email ou ID",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: _onSearchChanged,
    );
  }
}
