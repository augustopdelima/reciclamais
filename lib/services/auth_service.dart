import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email & password
  Future<User?> register(String email, String password, String nome) async {
    try {
      // 1. Criar usuário no Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = result.user;

      if (user != null) {
        // 2. Criar documento no Firestore com dados adicionais
        await _firestore.collection('users').doc(user.uid).set({
          'name': nome,
          'email': email.trim(),
          'points': 0, // usuário novo começa com 0 pontos
          'role': 'client', // padrão, não admin
          'createdAt':
              FieldValue.serverTimestamp(), // opcional, data de criação
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  Stream<Map<String, dynamic>?> listenUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data();
      }
      return null;
    });
  }

  // Login with email & password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

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

  // Login with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Para web, o GoogleSignIn pode ter limitações
      // Vamos usar uma abordagem mais direta
      if (kIsWeb) {
        // Usar GoogleAuthProvider diretamente para web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        
        // Configurar para desenvolvimento local
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
          'hosted_domain': 'gmail.com', // Remove para permitir qualquer domínio
        });
        
        // Sign in
        final UserCredential result = await _auth.signInWithPopup(googleProvider);
        final User? user = result.user;
        
        if (user != null) {
          // Verificar se é o primeiro login do usuário
          final userDoc = await _firestore.collection('users').doc(user.uid).get();
          
          if (!userDoc.exists) {
            // Primeiro login com Google - criar documento no Firestore
            await _firestore.collection('users').doc(user.uid).set({
              'name': user.displayName ?? 'Usuário Google',
              'email': user.email ?? '',
              'points': 0,
              'role': 'client',
              'createdAt': FieldValue.serverTimestamp(),
              'photoURL': user.photoURL,
              'loginMethod': 'google',
            });
          }
        }
        
        return user;
      } else {
        // Para mobile, usar GoogleSignIn
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential result = await _auth.signInWithCredential(credential);
        User? user = result.user;

        if (user != null) {
          final userDoc = await _firestore.collection('users').doc(user.uid).get();
          
          if (!userDoc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'name': user.displayName ?? 'Usuário Google',
              'email': user.email ?? '',
              'points': 0,
              'role': 'client',
              'createdAt': FieldValue.serverTimestamp(),
              'photoURL': user.photoURL,
              'loginMethod': 'google',
            });
          }
        }

        return user;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
