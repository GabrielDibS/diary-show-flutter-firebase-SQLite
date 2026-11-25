import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';
import 'views/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
    await SyncService.instance.iniciar();
  } catch (erro) {
    runApp(ErroConfiguracaoApp(mensagem: erro.toString()));
    return;
  }

  runApp(const DiarioShowsApp());
}

class DiarioShowsApp extends StatelessWidget {
  const DiarioShowsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diário de Shows',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.escuro,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashPage(),
    );
  }
}

class ErroConfiguracaoApp extends StatelessWidget {
  final String mensagem;

  const ErroConfiguracaoApp({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.escuro,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppCores.erro, size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'Não foi possível iniciar o aplicativo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppCores.textoPrimario, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mensagem,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppCores.textoSecundario, fontSize: 14),
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
