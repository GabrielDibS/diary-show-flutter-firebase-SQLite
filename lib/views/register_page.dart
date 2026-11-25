import 'package:flutter/material.dart';

import '../components/auth_layout.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/mensagem_erro.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  final _auth = AuthService();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await _auth.cadastrar(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
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
      mostrarVoltar: true,
      titulo: 'Criar conta',
      subtitulo: 'Cadastre-se para guardar seus shows na nuvem',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nomeController,
              label: 'Nome completo',
              icone: Icons.person_outline,
              acaoTeclado: TextInputAction.next,
              validator: Validators.nomeCompleto,
              habilitado: !_carregando,
            ),
            const SizedBox(height: 14),
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
              acaoTeclado: TextInputAction.next,
              validator: Validators.senha,
              habilitado: !_carregando,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _confirmarController,
              label: 'Confirmar senha',
              icone: Icons.lock_reset,
              senha: true,
              acaoTeclado: TextInputAction.done,
              validator: (valor) => Validators.confirmarSenha(valor, _senhaController.text),
              habilitado: !_carregando,
              onSubmitted: (_) => _cadastrar(),
            ),
            if (_erro != null) MensagemErro(mensagem: _erro!),
            const SizedBox(height: 20),
            CustomButton(
              texto: 'Criar conta',
              icone: Icons.person_add_alt,
              carregando: _carregando,
              onPressed: _cadastrar,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _carregando ? null : () => Navigator.pop(context),
              child: const Text('Já tenho conta'),
            ),
          ],
        ),
      ),
    );
  }
}
