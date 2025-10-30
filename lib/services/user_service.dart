import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/history.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  UserService(this.userId);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _redeemHistoryCollection =>
      _db.collection('redeem_history');
  CollectionReference<Map<String, dynamic>> get _collectionHistoryCollection =>
      _db.collection('collection_history');

  Future<UserModel> fetchUserProfile() async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        return UserModel(
          id: userId,
          name: "Usuário Desconhecido",
          email: "sem.email@exemplo.com",
          points: 0,
          createdAt: DateTime.now(),
          role: 'client',
        );
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      print('Erro ao buscar perfil do usuário: $e');
      rethrow;
    }
  }

  Future<List<RedeemHistoryItem>> fetchRedeemHistory() async {
    try {
      final querySnapshot = await _redeemHistoryCollection
          .where('userId', isEqualTo: userId)
          .orderBy('redeemedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RedeemHistoryItem.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar histórico de cupons: $e');
      return [];
    }
  }

  Future<List<CollectionHistoryItem>> fetchCollectionHistory() async {
    try {
      final querySnapshot = await _collectionHistoryCollection
          .where('userId', isEqualTo: userId)
          .orderBy('collectedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CollectionHistoryItem.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar histórico de coleções: $e');
      return [];
    }
  }
}
