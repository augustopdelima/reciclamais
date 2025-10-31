import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reciclamais/components/bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodel/ponto.dart';

class ListaPontosColetaPage extends StatefulWidget {
  const ListaPontosColetaPage({super.key});

  @override
  State<ListaPontosColetaPage> createState() => _ListaPontosColetaPageState();
}

class _ListaPontosColetaPageState extends State<ListaPontosColetaPage> {
  late PontosColetaViewModel viewModel;

  final List<String> materiais = ['Cobre', 'Alumínio', 'LDPE', 'HDPE', 'PET'];

  @override
  void initState() {
    super.initState();
    viewModel = context.read<PontosColetaViewModel>();
    viewModel.fetchPontos();
  }

  Future<void> abrirGoogleMaps(double latitude, double longitude) async {
    // Monta a URL universal do Google Maps
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Se não conseguir, lança uma exceção.
      throw 'Não foi possível abrir o Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pontos de Coleta')),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 3),
      body: Column(
        children: [
          // Filtro por materiais
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<PontosColetaViewModel>(
              builder: (context, vm, child) {
                return Wrap(
                  spacing: 8,
                  children: materiais.map((material) {
                    final selecionado = vm.materiaisSelecionados.contains(
                      material,
                    );
                    return FilterChip(
                      label: Text(material),
                      selected: selecionado,
                      onSelected: (_) => vm.toggleMaterial(material),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Lista de pontos
          Expanded(
            child: Consumer<PontosColetaViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.error != null) return Center(child: Text(vm.error!));
                if (vm.pontos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum ponto de coleta encontrado'),
                  );
                }

                return ListView.builder(
                  itemCount: vm.pontos.length,
                  itemBuilder: (context, index) {
                    final ponto = vm.pontos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(ponto.nome),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ponto.endereco),
                            if (ponto.telefone != null)
                              Text('Telefone: ${ponto.telefone}'),
                            if (ponto.horario != null)
                              Text('Horário: ${ponto.horario}'),
                            Text('Materiais: ${ponto.materiais.join(', ')}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.map, color: Colors.green),
                          onPressed: () =>
                              abrirGoogleMaps(ponto.latitude, ponto.longitude),
                        ),
                      ),
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
