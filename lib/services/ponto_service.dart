import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ponto.dart';

class PontosColetaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Busca todos os pontos de coleta
  Future<List<PontoColeta>> getPontos() async {
    final snapshot = await _firestore.collection('pontos_coletas').get();
    return snapshot.docs
        .map((doc) => PontoColeta.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Stream em tempo real
  Stream<List<PontoColeta>> getPontosStream() {
    return _firestore
        .collection('pontos_coletas')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PontoColeta.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
