import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_user.dart';

class AdminCreditPointsSheet extends StatefulWidget {
  const AdminCreditPointsSheet({super.key});

  @override
  State<AdminCreditPointsSheet> createState() => _AdminCreditPointsSheetState();
}

class _AdminCreditPointsSheetState extends State<AdminCreditPointsSheet> {
  final qtdCtrl = TextEditingController();
  final motivoCtrl = TextEditingController();

  String material = "Cobre";
  int pontosCalculados = 0;

  bool get isFormValid {
    final kg = double.tryParse(qtdCtrl.text) ?? 0;
    return kg > 0 && pontosCalculados > 0;
  }

  Future<void> _handleCreditarPontos(AdminViewModel vm) async {
    final user = vm.selectedUser;

    if (user == null) {
      print("Nenhum usuário selecionado!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nenhum usuário selecionado!")),
      );
      return;
    }

    print("Iniciando crédito de pontos para o usuário: ${user["id"]}");
    print(
      "Material: $material, Quantidade: ${qtdCtrl.text} kg, Pontos: $pontosCalculados",
    );

    try {
      await vm.creditarPontos(
        userId: user["id"],
        material: material,
        kg: double.tryParse(qtdCtrl.text) ?? 0,
        pontos: pontosCalculados,
        motivo: motivoCtrl.text,
      );

      print("Pontos creditados com sucesso!");

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pontos creditados com sucesso!")),
      );
    } catch (e) {
      print("Erro ao creditar pontos: $e");
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao creditar pontos")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        final user = vm.selectedUser;
        if (user == null) {
          return Center(
            child: Text(
              "Nenhum usuário selecionado",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
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
                  // Cabeçalho
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.green.shade300,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user["name"],
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Dropdown de Material
                  DropdownButtonFormField<String>(
                    initialValue: material,
                    decoration: fieldDecoration(),
                    items: vm.pontosPorKg.keys
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        material = value!;
                        _calcular(vm);
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  // Quantidade
                  TextField(
                    controller: qtdCtrl,
                    keyboardType: TextInputType.number,
                    decoration: fieldDecoration().copyWith(
                      hintText: "Quantidade (kg)",
                    ),
                    onChanged: (_) => _calcular(vm),
                  ),
                  const SizedBox(height: 15),
                  // Pontos calculados
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffc4f7a1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Pontos: $pontosCalculados",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Motivo
                  TextField(
                    controller: motivoCtrl,
                    decoration: fieldDecoration().copyWith(
                      hintText: "Motivo (opcional)",
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: isFormValid
                        ? () => _handleCreditarPontos(vm)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Creditar pontos",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xffc4f7a1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _calcular(AdminViewModel vm) {
    final kg = double.tryParse(qtdCtrl.text) ?? 0;
    setState(() {
      pontosCalculados = vm.calcularPontos(material, kg);
    });
  }
}
