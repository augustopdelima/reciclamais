import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  final String id; // ID legível (ex: RECICLA10)
  final String descricao;
  final double valorDesconto;
  final String tipoDesconto; // ex: 'percentual' ou 'fixo'
  final int costPoints; // Custo em pontos para resgatar
  final double
  maxPurchaseValue; // Valor máximo da compra para validade do cupom
  final String adminId;
  final String? assignedTo; // UID do usuário ou null
  final bool redeemed; // indica que o usuário comprou/resgatou
  final bool? spentByAdmin; // indica que o admin marcou como gasto
  final DateTime? spentAt; // data em que o admin marcou como gasto
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.descricao,
    required this.valorDesconto,
    required this.tipoDesconto,
    required this.costPoints,
    required this.maxPurchaseValue,
    required this.adminId,
    this.assignedTo,
    required this.redeemed,
    this.spentByAdmin,
    this.spentAt,
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

    final rawCost = data['costPoints'];
    int parsedCost = 0;
    if (rawCost is int) {
      parsedCost = rawCost;
    } else if (rawCost is double) {
      parsedCost = rawCost.round();
    }

    final rawMaxValue = data['maxPurchaseValue'];
    double parsedMaxValue = 0;
    if (rawMaxValue is int) {
      parsedMaxValue = rawMaxValue.toDouble();
    } else if (rawMaxValue is double) {
      parsedMaxValue = rawMaxValue;
    }

    return Coupon(
      id: data['id'] ?? documentId,
      descricao: data['descricao'] ?? '',
      valorDesconto: parsedValor,
      tipoDesconto: data['tipoDesconto'] ?? 'percentual',
      costPoints: parsedCost,
      maxPurchaseValue: parsedMaxValue,
      adminId: data['adminId'] ?? '',
      assignedTo: data['assignedTo'] ?? data['usuarioId'],
      redeemed: data['redeemed'] ?? false,
      spentByAdmin: data['spentByAdmin'],
      spentAt: data['spentAt'] != null
          ? (data['spentAt'] as Timestamp).toDate()
          : null,
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
      'costPoints': costPoints,
      'maxPurchaseValue': maxPurchaseValue,
      'adminId': adminId,
      'assignedTo': assignedTo,
      'redeemed': redeemed,
      'spentByAdmin': spentByAdmin,
      'spentAt': spentAt,
      'createdAt': createdAt,
    };
  }

  /// Cria uma cópia modificada do objeto
  Coupon copyWith({
    String? id,
    String? descricao,
    double? valorDesconto,
    String? tipoDesconto,
    int? costPoints,
    double? maxPurchaseValue,
    String? adminId,
    String? assignedTo,
    bool? redeemed,
    bool? spentByAdmin,
    DateTime? spentAt,
    DateTime? createdAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valorDesconto: valorDesconto ?? this.valorDesconto,
      tipoDesconto: tipoDesconto ?? this.tipoDesconto,
      costPoints: costPoints ?? this.costPoints,
      maxPurchaseValue: maxPurchaseValue ?? this.maxPurchaseValue,
      adminId: adminId ?? this.adminId,
      assignedTo: assignedTo ?? this.assignedTo,
      redeemed: redeemed ?? this.redeemed,
      spentByAdmin: spentByAdmin ?? this.spentByAdmin,
      spentAt: spentAt ?? this.spentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
