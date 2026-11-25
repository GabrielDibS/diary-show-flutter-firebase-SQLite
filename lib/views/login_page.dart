import 'package:flutter/material.dart';

import '../components/auth_layout.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/mensagem_erro.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _auth = AuthService();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await _auth.entrar(
        email: _emailController.text,
        senha: _senhaController.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (rota) => false,
      );
    } on AuthException catch (e) {
      setState(() => _erro = e.toString());
    } catch (_) {
      setState(() => _erro = 'Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      titulo: 'Bem-vindo de volta',
      subtitulo: 'Entre para ver o seu diário de shows',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _emailController,
              label: 'E-mail',
              icone: Icons.email_outlined,
              teclado: TextInputType.emailAddress,
              acaoTeclado: TextInputAction.next,
              validator: Validators.email,
              habilitado: !_carregando,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _senhaController,
              label: 'Senha',
              icone: Icons.lock_outline,
              senha: true,
              acaoTeclado: TextInputAction.done,
              validator: Validators.senha,
              habilitado: !_carregando,
              onSubmitted: (_) => _entrar(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _carregando
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                        ),
                child: const Text('Recuperar senha'),
              ),
            ),
            if (_erro != null) MensagemErro(mensagem: _erro!),
            const SizedBox(height: 12),
            CustomButton(
              texto: 'Entrar',
              icone: Icons.login,
              carregando: _carregando,
              onPressed: _entrar,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _carregando
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      ),
              child: const Text('Não tem conta? Cadastre-se aqui'),
            ),
          ],
        ),
      ),
    );
  }
}
