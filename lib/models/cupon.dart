import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  final String id; // ID legível (ex: RECICLA10)
  final String descricao;
  final double valorDesconto;
  final String tipoDesconto; // ex: 'percentual' ou 'fixo'
  final String adminId;
  final String? assignedTo; // UID do usuário ou null
  final bool redeemed;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.descricao,
    required this.valorDesconto,
    required this.tipoDesconto,
    required this.adminId,
    this.assignedTo,
    required this.redeemed,
    required this.createdAt,
  });

  /// Converte dados do Firestore para um objeto Coupon
  factory Coupon.fromFirestore(Map<String, dynamic> data, String documentId) {
    final rawValor = data['valorDesconto'];

    double parsedValor = 0;
    if (rawValor is int) {
      parsedValor = rawValor.toDouble();
    } else if (rawValor is double) {
      parsedValor = rawValor;
    } else if (rawValor is String) {
      parsedValor = double.tryParse(rawValor) ?? 0;
    }

    return Coupon(
      id: data['id'] ?? documentId,
      descricao: data['descricao'] ?? '',
      valorDesconto: parsedValor,
      tipoDesconto: data['tipoDesconto'] ?? 'percentual',
      adminId: data['adminId'] ?? '',
      assignedTo: data['assignedTo'] ?? data['usuarioId'],
      redeemed: data['redeemed'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Converte o objeto para o formato do Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'descricao': descricao,
      'valorDesconto': valorDesconto,
      'tipoDesconto': tipoDesconto,
      'adminId': adminId,
      'assignedTo': assignedTo,
      'redeemed': redeemed,
      'createdAt': createdAt,
    };
  }

  /// Cria uma cópia modificada do objeto
  Coupon copyWith({
    String? id,
    String? descricao,
    double? valorDesconto,
    String? tipoDesconto,
    String? adminId,
    String? assignedTo,
    bool? redeemed,
    DateTime? createdAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valorDesconto: valorDesconto ?? this.valorDesconto,
      tipoDesconto: tipoDesconto ?? this.tipoDesconto,
      adminId: adminId ?? this.adminId,
      assignedTo: assignedTo ?? this.assignedTo,
      redeemed: redeemed ?? this.redeemed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
