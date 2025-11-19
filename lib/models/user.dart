import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final DateTime createdAt; // Data de criação (convertida de Timestamp)
  final String email;
  final String name;
  final int points;
  final String role;

  UserModel({
    required this.id,
    required this.createdAt,
    required this.email,
    required this.name,
    required this.points,
    required this.role,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    final createdAtTimestamp = data?['createdAt'] as Timestamp?;
    final createdAt = createdAtTimestamp?.toDate() ?? DateTime.now();

    return UserModel(
      id: doc.id,
      createdAt: createdAt,
      email: data?['email'] ?? 'N/A',
      name: data?['name'] ?? 'Usuário',
      // Usa 'num' para garantir que lide com int ou double do Firestore antes de converter para int.
      points: (data?['points'] as num?)?.toInt() ?? 0,
      role: data?['role'] ?? 'client',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'points': points,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      points: json['points'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
