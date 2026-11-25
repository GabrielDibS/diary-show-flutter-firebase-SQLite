import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_sync_bar.dart';
import 'albuns_page.dart';
import 'artista_page.dart';
import 'calendar_page.dart';
import 'login_page.dart';
import 'registros_page.dart';
import 'top_track_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    SyncService.instance.atualizarPendentes();
    SyncService.instance.sincronizar();
  }

  Future<void> _sair() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar sessão?'),
        content: const Text('Os registros ainda não enviados continuam salvos no aparelho.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await _auth.sair();
    await SyncService.instance.atualizarPendentes();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (rota) => false,
    );
  }

  void _abrir(Widget pagina) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    final nome = _auth.nomeExibicao;
    final inicial = nome.isEmpty ? '?' : nome.substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Shows', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: LayoutBuilder(
              builder: (context, restricoes) {
                const espaco = 12.0;
                final larguraUtil = restricoes.maxWidth - 40;
                final duasColunas = larguraUtil >= 560;
                final larguraCartao = duasColunas ? (larguraUtil - espaco) / 2 : larguraUtil;

                Widget cartao(IconData icone, String titulo, String subtitulo, Widget pagina) {
                  return SizedBox(
                    width: larguraCartao,
                    child: _CartaoMenu(
                      icone: icone,
                      titulo: titulo,
                      subtitulo: subtitulo,
                      onTap: () => _abrir(pagina),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppCores.primaria, Color(0xFF5B3FD6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: Text(
                              inicial,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Olá,', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text(
                                  nome,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _auth.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const StatusSyncBar(),
                    const SizedBox(height: 22),
                    const _Secao(titulo: 'Meu diário'),
                    Wrap(
                      spacing: espaco,
                      runSpacing: espaco,
                      children: [
                        cartao(Icons.confirmation_number_outlined, 'Meus shows', 'Cadastre, edite e exclua seus shows', const RegistrosPage()),
                        cartao(Icons.calendar_month, 'Calendário', 'Veja os shows por data', const CalendarPage()),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _Secao(titulo: 'Explorar músicas (API TheAudioDB)'),
                    Wrap(
                      spacing: espaco,
                      runSpacing: espaco,
                      children: [
                        cartao(Icons.person, 'Artista', 'Fotos, biografia e redes sociais', const ArtistaPage()),
                        cartao(Icons.music_note, 'Música mais tocada', 'A faixa em destaque do artista', const TopTrackPage()),
                        cartao(Icons.album, 'Álbuns', 'Álbum e ano de lançamento', const AlbunsPage()),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;

  const _Secao({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        titulo,
        style: const TextStyle(
          color: AppCores.textoSecundario,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _CartaoMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _CartaoMenu({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppCores.superficie,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppCores.primaria.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: AppCores.primariaClara, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppCores.textoPrimario,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(color: AppCores.textoSecundario, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppCores.textoSecundario),
            ],
          ),
        ),
      ),
    );
  }
}
