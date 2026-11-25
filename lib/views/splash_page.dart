import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacidade;
  late final Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _opacidade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _escala = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _decidirProximaTela();
  }

  Future<void> _decidirProximaTela() async {
    final sessao = AuthService().carregarSessao();
    await Future.delayed(const Duration(milliseconds: 2200));
    final usuario = await sessao;
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => usuario != null ? const HomePage() : const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppCores.fundo, Color(0xFF241B45)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacidade,
            child: ScaleTransition(
              scale: _escala,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/imagens/logo.png',
                    height: 140,
                    errorBuilder: (context, erro, stack) => const Icon(
                      Icons.music_note,
                      size: 100,
                      color: AppCores.primariaClara,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Diário de Shows',
                    style: TextStyle(
                      color: AppCores.textoPrimario,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Seus shows, onde e quando quiser',
                    style: TextStyle(color: AppCores.textoSecundario, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppCores.primariaClara,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
