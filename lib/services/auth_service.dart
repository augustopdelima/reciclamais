import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login com e-mail e senha
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro com e-mail e senha
  Future<UserCredential?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('Verificando se o email já existe: $email');
      
      // Verificar se o usuário já existe no Firestore
      var usersWithEmail = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (usersWithEmail.docs.isNotEmpty) {
        print('Email já cadastrado no Firestore');
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Este e-mail já está cadastrado no sistema.',
        );
      }

      print('Iniciando registro do usuário: $email');
      
      // Criar usuário no Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Usuário criado no Auth com ID: ${result.user?.uid}');

      // Adicionar informações adicionais no Firestore
      try {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Dados do usuário salvos no Firestore');
      } catch (firestoreError) {
        print('Erro ao salvar no Firestore: $firestoreError');
        // Deletar o usuário do Auth se falhar ao salvar no Firestore
        await result.user?.delete();
        throw 'Erro ao salvar dados do usuário. Por favor, tente novamente.';
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('Erro no Firebase Auth: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Erro não esperado: $e');
      throw 'Ocorreu um erro inesperado. Por favor, tente novamente.';
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Limpar cadastro existente
  Future<void> deleteAccount(String email, String password) async {
    try {
      // Fazer login primeiro
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Deletar dados do Firestore
      await _firestore.collection('users').doc(result.user!.uid).delete();
      
      // Deletar usuário do Auth
      await result.user!.delete();
      
      print('Conta deletada com sucesso');
    } catch (e) {
      print('Erro ao deletar conta: $e');
      throw 'Erro ao deletar conta. Por favor, tente novamente.';
    }
  }

  // Tratamento de erros
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      default:
        return 'Ocorreu um erro: ${e.message}';
    }
  }
}