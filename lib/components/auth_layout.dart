import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AuthLayout extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget child;
  final bool mostrarVoltar;

  const AuthLayout({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.child,
    this.mostrarVoltar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mostrarVoltar
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/imagens/logo.png',
                    height: 96,
                    errorBuilder: (context, erro, stack) => const Icon(
                      Icons.music_note,
                      size: 72,
                      color: AppCores.primariaClara,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppCores.textoPrimario,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppCores.textoSecundario, fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
