import 'package:flutter/material.dart';

import '../components/auth_layout.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/mensagem_erro.dart';
import '../widgets/mensagem_sucesso.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = AuthService();

  bool _carregando = false;
  String? _erro;
  String? _sucesso;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
      _sucesso = null;
    });

    try {
      await _auth.recuperarSenha(_emailController.text);
      setState(() {
        _sucesso =
            'Solicitação enviada! Se o e-mail estiver cadastrado, você receberá um link para redefinir a senha. Verifique também a caixa de spam.';
      });
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
      mostrarVoltar: true,
      titulo: 'Recuperar senha',
      subtitulo: 'Enviaremos um link de redefinição para o seu e-mail',
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
              acaoTeclado: TextInputAction.done,
              validator: Validators.email,
              habilitado: !_carregando,
              onSubmitted: (_) => _enviar(),
            ),
            if (_erro != null) MensagemErro(mensagem: _erro!),
            if (_sucesso != null) MensagemSucesso(mensagem: _sucesso!),
            const SizedBox(height: 20),
            CustomButton(
              texto: 'Enviar link',
              icone: Icons.send,
              carregando: _carregando,
              onPressed: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}
