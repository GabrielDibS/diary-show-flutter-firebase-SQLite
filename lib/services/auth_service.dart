import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioAtual => _auth.currentUser;

  String? get uid => _auth.currentUser?.uid;

  String get nomeExibicao {
    final usuario = _auth.currentUser;
    if (usuario == null) return '';
    final nome = usuario.displayName;
    if (nome != null && nome.trim().isNotEmpty) return nome;
    return usuario.email ?? '';
  }

  String get email => _auth.currentUser?.email ?? '';

  Future<User?> carregarSessao() async {
    try {
      return await _auth.authStateChanges().first.timeout(const Duration(seconds: 5));
    } catch (_) {
      return _auth.currentUser;
    }
  }

  Future<void> entrar({required String email, required String senha}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: senha);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e));
    }
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      await credencial.user?.updateDisplayName(nome.trim());
      await credencial.user?.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e));
    }
  }

  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e));
    }
  }

  Future<void> sair() => _auth.signOut();

  String _traduzir(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com esse e-mail.';
      case 'weak-password':
        return 'Senha fraca. Use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas seguidas. Aguarde um pouco e tente novamente.';
      case 'operation-not-allowed':
        return 'O login por e-mail e senha não está habilitado no Firebase.';
      default:
        return 'Erro de autenticação (${e.code}).';
    }
  }
}
