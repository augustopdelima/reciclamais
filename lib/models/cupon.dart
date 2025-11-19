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
  final bool redeemed;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.descricao,
    required this.valorDesconto,
    required this.tipoDesconto,
    required this.costPoints, // Adicionado no construtor
    required this.maxPurchaseValue, // Adicionado no construtor
    required this.adminId,
    this.assignedTo,
    required this.redeemed,
    required this.createdAt,
  });

  /// Converte dados do Firestore para um objeto Coupon
  factory Coupon.fromFirestore(Map<String, dynamic> data, String documentId) {
    final rawValor = data['valorDesconto'];

    // Lógica para parsear valorDesconto
    double parsedValor = 0;
    if (rawValor is int) {
      parsedValor = rawValor.toDouble();
    } else if (rawValor is double) {
      parsedValor = rawValor;
    } else if (rawValor is String) {
      parsedValor = double.tryParse(rawValor) ?? 0;
    }

    // Lógica para parsear costPoints (deve ser int)
    final rawCost = data['costPoints'];
    int parsedCost = 0;
    if (rawCost is int) {
      parsedCost = rawCost;
    } else if (rawCost is double) {
      parsedCost = rawCost.round();
    }

    // Lógica para parsear maxPurchaseValue (deve ser double)
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

      //  Atribuição dos NOVOS CAMPOS
      costPoints: parsedCost,
      maxPurchaseValue: parsedMaxValue,

      // -----------------------------
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
      'costPoints': costPoints, // Incluído
      'maxPurchaseValue': maxPurchaseValue, // Incluído
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
    int? costPoints, // Incluído
    double? maxPurchaseValue, // Incluído
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
      costPoints: costPoints ?? this.costPoints,
      maxPurchaseValue: maxPurchaseValue ?? this.maxPurchaseValue,
      adminId: adminId ?? this.adminId,
      assignedTo: assignedTo ?? this.assignedTo,
      redeemed: redeemed ?? this.redeemed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
