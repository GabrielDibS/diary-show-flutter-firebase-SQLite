import 'package:flutter/material.dart';

import '../models/registro_model.dart';
import '../services/registro_firebase.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../widgets/carregando_view.dart';
import '../widgets/mensagem_erro.dart';
import '../widgets/registro_tile.dart';
import '../widgets/status_sync_bar.dart';
import 'details_page.dart';
import 'registro_form_page.dart';

class RegistrosPage extends StatefulWidget {
  const RegistrosPage({super.key});

  @override
  State<RegistrosPage> createState() => _RegistrosPageState();
}

class _RegistrosPageState extends State<RegistrosPage> {
  final _repo = RegistroRepository();
  final _sync = SyncService.instance;

  List<Registro> _registros = [];
  bool _nuvemDisponivel = true;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
    _sync.versao.addListener(_carregar);
  }

  @override
  void dispose() {
    _sync.versao.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final resultado = await _repo.listar();
      if (!mounted) return;
      setState(() {
        _registros = resultado.registros;
        _nuvemDisponivel = resultado.nuvemDisponivel;
        _erro = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar os registros.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _novo() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RegistroFormPage()),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _abrirDetalhes(Registro registro) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsPage(registro: registro)),
    );
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Meus shows', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novo,
        icon: const Icon(Icons.add),
        label: const Text('Novo show'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  const StatusSyncBar(),
                  if (!_nuvemDisponivel && !_carregando)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppCores.destaque.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Modo offline: exibindo apenas os registros ainda não enviados à nuvem.',
                        style: TextStyle(color: AppCores.destaque, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(child: _conteudo()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Center(child: CarregandoView(mensagem: 'Carregando seus shows...'));
    }
    if (_erro != null) {
      return Align(alignment: Alignment.topCenter, child: MensagemErro(mensagem: _erro!));
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: _registros.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Icon(Icons.music_note, size: 56, color: AppCores.superficieClara),
                SizedBox(height: 12),
                Text(
                  'Nenhum show cadastrado ainda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppCores.textoPrimario, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Toque em "Novo show" para registrar o primeiro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppCores.textoSecundario, fontSize: 13),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: _registros.length,
              itemBuilder: (context, i) {
                final registro = _registros[i];
                return RegistroTile(registro: registro, onTap: () => _abrirDetalhes(registro));
              },
            ),
    );
  }
}
