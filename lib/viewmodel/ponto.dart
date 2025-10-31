import 'package:flutter/material.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';

class PontosColetaViewModel extends ChangeNotifier {
  final PontosColetaService _service;

  PontosColetaViewModel([PontosColetaService? service])
    : _service = service ?? PontosColetaService();

  List<PontoColeta> _todosPontos = [];
  List<PontoColeta> _pontosFiltrados = [];
  List<PontoColeta> get pontos => _pontosFiltrados;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<String> _materiaisSelecionados = [];
  List<String> get materiaisSelecionados => _materiaisSelecionados;

  Future<void> fetchPontos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todosPontos = await _service.getPontos();
      _pontosFiltrados = List.from(_todosPontos);
    } catch (e) {
      _error = 'Erro ao carregar pontos de coleta: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void listenPontos() {
    _service.getPontosStream().listen(
      (data) {
        _todosPontos = data;
        _aplicarFiltro();
      },
      onError: (e) {
        _error = 'Erro ao atualizar pontos de coleta: $e';
        notifyListeners();
      },
    );
  }

  void toggleMaterial(String material) {
    if (_materiaisSelecionados.contains(material)) {
      _materiaisSelecionados.remove(material);
    } else {
      _materiaisSelecionados.add(material);
    }
    _aplicarFiltro();
  }

  void _aplicarFiltro() {
    if (_materiaisSelecionados.isEmpty) {
      _pontosFiltrados = List.from(_todosPontos);
    } else {
      _pontosFiltrados = _todosPontos.where((ponto) {
        return ponto.materiais.any((m) => _materiaisSelecionados.contains(m));
      }).toList();
    }
    notifyListeners();
  }
}
