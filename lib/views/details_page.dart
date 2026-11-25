import 'dart:io';

import 'package:flutter/material.dart';

import '../models/registro_model.dart';
import '../services/api_exceptions.dart';
import '../services/api_service.dart';
import '../services/registro_firebase.dart';
import '../theme/app_theme.dart';
import '../utils/abrir_link.dart';
import '../utils/formatadores.dart';
import '../widgets/carregando_view.dart';
import '../widgets/chip_info.dart';
import '../widgets/imagem_resultado.dart';
import 'registro_form_page.dart';

class DetailsPage extends StatefulWidget {
  final Registro registro;

  const DetailsPage({super.key, required this.registro});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final _repo = RegistroRepository();
  final _api = ApiService();

  late final Future<Map<String, dynamic>> _artistaFuture;
  bool _excluindo = false;

  Registro get _registro => widget.registro;

  @override
  void initState() {
    super.initState();
    _artistaFuture = _api.buscaArtista(_registro.artista);
  }

  Future<void> _editar() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => RegistroFormPage(registro: _registro)),
    );
    if (salvou == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir show?'),
        content: Text('O registro "${_registro.titulo}" será removido. Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    setState(() => _excluindo = true);
    try {
      await _repo.excluir(_registro);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Show excluído.')),
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o registro.')),
      );
    } finally {
      if (mounted) setState(() => _excluindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalhes do show', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _excluindo ? null : _editar,
          ),
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
            onPressed: _excluindo ? null : _excluir,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _foto(),
                  Text(
                    _registro.titulo,
                    style: const TextStyle(color: AppCores.textoPrimario, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _registro.artista,
                    style: const TextStyle(color: AppCores.primariaClara, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChipInfo(rotulo: 'Situação', valor: _registro.synced ? 'Sincronizado' : 'Pendente de envio'),
                      ChipInfo(rotulo: 'Criado em', valor: formatarData(_registro.dataCriacao)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _linha(Icons.event, 'Data', formatarDataExtenso(_registro.dataEvento)),
                  _linha(Icons.place_outlined, 'Local', valorOuNulo(_registro.local) ?? '---'),
                  _linha(Icons.notes, 'Descrição', valorOuNulo(_registro.descricao) ?? '---'),
                  _blocoLocalizacao(),
                  const SizedBox(height: 20),
                  _blocoArtista(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _foto() {
    final caminho = _registro.imagemPath;
    if (caminho == null || !File(caminho).existsSync()) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.file(File(caminho), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _linha(IconData icone, String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppCores.primariaClara, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo, style: const TextStyle(color: AppCores.textoSecundario, fontSize: 12)),
                Text(valor, style: const TextStyle(color: AppCores.textoPrimario, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blocoLocalizacao() {
    if (!_registro.temLocalizacao) {
      return _linha(Icons.my_location, 'Coordenadas', '---');
    }

    final lat = _registro.latitude!;
    final lng = _registro.longitude!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linha(
          Icons.my_location,
          'Coordenadas',
          'Lat ${formatarCoordenada(lat)} · Lng ${formatarCoordenada(lng)}',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => abrirLink(
              context,
              'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
            ),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Abrir no mapa'),
          ),
        ),
      ],
    );
  }

  Widget _blocoArtista() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _artistaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CarregandoView(mensagem: 'Buscando dados do artista...');
        }

        if (snapshot.hasError) {
          final erro = snapshot.error;
          final mensagem = (erro is ApiException || erro is ConnectionException)
              ? erro.toString()
              : 'Não foi possível carregar os dados do artista.';
          return Text(
            'Informações do artista indisponíveis: $mensagem',
            style: const TextStyle(color: AppCores.textoSecundario, fontSize: 13),
          );
        }

        final artista = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppCores.superficie,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                child: ImagemResultado(
                  url: valorOuNulo(artista['strArtistThumb']),
                  aspectRatio: 1,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sobre o artista (TheAudioDB)',
                      style: TextStyle(color: AppCores.textoSecundario, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artista['strArtist']?.toString() ?? _registro.artista,
                      style: const TextStyle(
                        color: AppCores.textoPrimario,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        valorOuNulo(artista['strGenre']),
                        valorOuNulo(artista['strCountry']),
                      ].whereType<String>().join(' · '),
                      style: const TextStyle(color: AppCores.textoSecundario, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
