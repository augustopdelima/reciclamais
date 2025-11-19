import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];

  Map<String, dynamic>? selectedUser;
  StreamSubscription? _sub;

  final Map<String, int> pontosPorKg = {
    "Cobre": 1260,
    "Alumínio": 360,
    "LDPE": 150,
    "HDPE": 90,
    "PET": 12,
  };

  int calcularPontos(String material, double kg) {
    final pontos = pontosPorKg[material] ?? 0;
    return (pontos * kg).round();
  }

  Future<void> creditarPontos({
    required String userId,
    required String material,
    required double kg,
    required int pontos,
    String? motivo,
  }) async {
    print("Entrou no creditarPontos: $userId, $material, $kg, $pontos");
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();

    await db.collection("transactions").add({
      "userId": userId,
      "material": material,
      "kg": kg,
      "motivo": motivo ?? "",
      "createdAt": now,
      'timestamp': FieldValue.serverTimestamp(),
      "amount": pontos,
    });

    await db.collection("collection_history").add({
      "userId": userId,
      "itemId": material,
      "description": motivo ?? "Crédito por entrega de $material",
      "pointsEarned": pontos,
      "collectedAt": now,
    });

    await db.collection("users").doc(userId).update({
      "points": FieldValue.increment(pontos),
    });
  }

  void startListener() {
    _sub = _service.listenClients().listen((users) {
      _allUsers = users;
      filteredUsers = users;
      notifyListeners();
    });
  }

  void search(String query) {
    filteredUsers = _allUsers
        .where(
          (u) =>
              u["name"].toLowerCase().contains(query.toLowerCase()) ||
              u["email"].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    notifyListeners();
  }

  void selectUser(Map<String, dynamic> user) {
    selectedUser = user;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
