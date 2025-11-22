import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reciclamais/components/admin_nav_bar.dart';
import '../viewmodel/admin_cupon.dart';
import '../models/cupon.dart';

class AdminCouponsPage extends StatelessWidget {
  const AdminCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminCouponsViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text("Gerenciar Cupons"),
          elevation: 0,
          backgroundColor: Colors.green.shade600,
        ),
        bottomNavigationBar: CustomBottomBarAdmin(currentIndex: 1),
        body: Consumer<AdminCouponsViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                  child: _SearchBar(vm: vm),
                ),
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.coupons.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum cupom encontrado para sua pesquisa",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: vm.coupons.length,
                          itemBuilder: (context, index) {
                            final cupom = vm.coupons[index];
                            final user = cupom.assignedTo != null
                                ? vm.getUserForCoupon(cupom.assignedTo!)
                                : null;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.local_offer_rounded,
                                          size: 32,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cupom.descricao,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text("Pontos: ${cupom.costPoints}"),
                                            Text("ID: ${cupom.id}"),
                                            Text(
                                              "Resgatado: ${cupom.redeemed ? 'Sim' : 'Não'}",
                                              style: TextStyle(
                                                color: cupom.redeemed
                                                    ? Colors.red
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                            if (user != null)
                                              Text(
                                                "Comprado por: ${user.name} (${user.email})",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.info_outline_rounded,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                        onPressed: () =>
                                            _showBottomConfirmation(
                                              context,
                                              cupom,
                                              vm,
                                            ),
                                      ),
                                    ],
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
      backgroundColor: Colors.black.withAlpha(51),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (_, controller) {
          final user = cupom.assignedTo != null
              ? vm.getUserForCoupon(cupom.assignedTo!)
              : null;

          return Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_offer_rounded,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Detalhes do Cupom",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                _infoText("Descrição", cupom.descricao),
                _infoText("Pontos", "${cupom.costPoints}"),
                _infoText("ID do Cupom", cupom.id),
                _infoText("Resgatado", cupom.redeemed ? "Sim" : "Não"),

                if (user != null)
                  _infoText("Comprado por", "${user.name} (${user.email})"),

                _infoText("Criado em", cupom.createdAt.toString()),

                if (cupom.spentByAdmin != null)
                  _infoText(
                    "Marcado por admin",
                    cupom.spentByAdmin! ? "Sim" : "Não",
                  ),

                if (cupom.spentAt != null)
                  _infoText("Data gasto", cupom.spentAt.toString()),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Marcar como gasto",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        final adminId = FirebaseAuth.instance.currentUser!.uid;
                        final success = await vm.markAsSpent(cupom.id, adminId);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: success
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            duration: const Duration(seconds: 3),
                            content: Row(
                              children: [
                                Icon(
                                  success
                                      ? Icons.check_circle_outline
                                      : Icons.error_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    success
                                        ? "Cupom marcado como gasto com sucesso!"
                                        : "Não foi possível marcar o cupom. Tente novamente.",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

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
      decoration: InputDecoration(
        hintText: "Buscar cupons...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: _onSearchChanged,
    );
  }
}
