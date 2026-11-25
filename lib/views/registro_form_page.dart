import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../models/registro_model.dart';
import '../services/location_service.dart';
import '../services/registro_firebase.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatadores.dart';
import '../utils/validators.dart';
import '../widgets/mensagem_erro.dart';

class RegistroFormPage extends StatefulWidget {
  final Registro? registro;
  final DateTime? dataInicial;

  const RegistroFormPage({super.key, this.registro, this.dataInicial});

  @override
  State<RegistroFormPage> createState() => _RegistroFormPageState();
}

class _RegistroFormPageState extends State<RegistroFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _artistaController = TextEditingController();
  final _localController = TextEditingController();
  final _descricaoController = TextEditingController();

  final _repo = RegistroRepository();
  final _location = LocationService();
  final _picker = ImagePicker();

  DateTime? _data;
  double? _latitude;
  double? _longitude;
  String? _imagemPath;

  bool _salvando = false;
  bool _obtendoLocalizacao = false;
  String? _erroData;
  String? _erro;

  bool get _editando => widget.registro != null;

  @override
  void initState() {
    super.initState();
    final registro = widget.registro;
    if (registro != null) {
      _tituloController.text = registro.titulo;
      _artistaController.text = registro.artista;
      _localController.text = registro.local;
      _descricaoController.text = registro.descricao;
      _data = registro.dataEvento;
      _latitude = registro.latitude;
      _longitude = registro.longitude;
      _imagemPath = registro.imagemPath;
    } else {
      _data = widget.dataInicial;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _artistaController.dispose();
    _localController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      helpText: 'Data do show',
    );
    if (escolhida != null) {
      setState(() {
        _data = escolhida;
        _erroData = null;
      });
    }
  }

  Future<void> _obterLocalizacao() async {
    if (await _location.permissaoPendente()) {
      if (!mounted) return;
      final aceitou = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Usar sua localização?'),
          content: const Text(
            'O aplicativo usa o GPS apenas para registrar as coordenadas do local onde o show aconteceu. A localização não é compartilhada com outras pessoas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Agora não'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (aceitou != true) return;
    }

    setState(() => _obtendoLocalizacao = true);
    try {
      final posicao = await _location.obterPosicaoAtual();
      if (!mounted) return;
      setState(() {
        _latitude = posicao.latitude;
        _longitude = posicao.longitude;
      });
    } on LocalizacaoException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.sugerirConfiguracoes
              ? SnackBarAction(
                  label: 'Configurações',
                  onPressed: _location.abrirConfiguracoesDoApp,
                )
              : null,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível obter a localização.')),
      );
    } finally {
      if (mounted) setState(() => _obtendoLocalizacao = false);
    }
  }

  Future<void> _escolherImagem(ImageSource fonte) async {
    try {
      final arquivo = await _picker.pickImage(
        source: fonte,
        maxWidth: 1280,
        imageQuality: 70,
      );
      if (arquivo == null) return;

      final pasta = await getApplicationDocumentsDirectory();
      final destino = '${pasta.path}/foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(arquivo.path).copy(destino);

      if (!mounted) return;
      setState(() => _imagemPath = destino);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível selecionar a imagem.')),
      );
    }
  }

  Future<void> _salvar() async {
    final formularioOk = _formKey.currentState!.validate();
    if (_data == null) {
      setState(() => _erroData = 'Escolha a data do show.');
    }
    if (!formularioOk || _data == null) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      final existente = widget.registro;
      if (existente == null) {
        final novo = _repo.novo(
          titulo: _tituloController.text.trim(),
          artista: _artistaController.text.trim(),
          local: _localController.text.trim(),
          descricao: _descricaoController.text.trim(),
          dataEvento: _data!,
          latitude: _latitude,
          longitude: _longitude,
          imagemPath: _imagemPath,
        );
        await _repo.salvar(novo);
      } else {
        final atualizado = existente.copyWith(
          titulo: _tituloController.text.trim(),
          artista: _artistaController.text.trim(),
          local: _localController.text.trim(),
          descricao: _descricaoController.text.trim(),
          dataEvento: _data,
          latitude: _latitude,
          longitude: _longitude,
          imagemPath: _imagemPath,
        );
        await _repo.salvar(atualizado);
      }

      if (!mounted) return;
      final online = SyncService.instance.online.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            online
                ? 'Show salvo!'
                : 'Show salvo no aparelho. Será enviado à nuvem quando a internet voltar.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (_) {
      setState(() => _erro = 'Não foi possível salvar o registro. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _salvando ? null : () => Navigator.pop(context, false),
        ),
        title: Text(
          _editando ? 'Editar show' : 'Novo show',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _tituloController,
                      label: 'Título do show',
                      hint: 'Ex: Turnê Music of the Spheres',
                      icone: Icons.title,
                      acaoTeclado: TextInputAction.next,
                      validator: (v) => Validators.campoObrigatorio(v, mensagem: 'Informe o título.'),
                      habilitado: !_salvando,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _artistaController,
                      label: 'Artista ou banda',
                      hint: 'Ex: Coldplay',
                      icone: Icons.person_outline,
                      acaoTeclado: TextInputAction.next,
                      validator: Validators.nomeArtista,
                      habilitado: !_salvando,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _localController,
                      label: 'Local (casa de shows, cidade)',
                      icone: Icons.place_outlined,
                      acaoTeclado: TextInputAction.next,
                      habilitado: !_salvando,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _descricaoController,
                      label: 'Descrição ou anotações',
                      icone: Icons.notes,
                      maxLinhas: 4,
                      teclado: TextInputType.multiline,
                      habilitado: !_salvando,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _salvando ? null : _escolherData,
                      icon: const Icon(Icons.event),
                      label: Text(_data == null ? 'Escolher data do show' : formatarData(_data!)),
                    ),
                    if (_erroData != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(_erroData!, style: const TextStyle(color: AppCores.erro, fontSize: 12)),
                      ),
                    const SizedBox(height: 16),
                    _blocoLocalizacao(),
                    const SizedBox(height: 16),
                    _blocoImagem(),
                    if (_erro != null) MensagemErro(mensagem: _erro!),
                    const SizedBox(height: 24),
                    CustomButton(
                      texto: _editando ? 'Salvar alterações' : 'Salvar show',
                      icone: Icons.save_outlined,
                      carregando: _salvando,
                      onPressed: _salvar,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _salvando ? null : () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _blocoLocalizacao() {
    final temLocalizacao = _latitude != null && _longitude != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Localização do show',
            style: TextStyle(color: AppCores.textoPrimario, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            temLocalizacao
                ? 'Latitude: ${formatarCoordenada(_latitude!)}\nLongitude: ${formatarCoordenada(_longitude!)}'
                : 'Nenhuma coordenada registrada.',
            style: const TextStyle(color: AppCores.textoSecundario, fontSize: 13),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: (_salvando || _obtendoLocalizacao) ? null : _obterLocalizacao,
            icon: _obtendoLocalizacao
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(temLocalizacao ? 'Atualizar localização' : 'Obter localização atual'),
          ),
        ],
      ),
    );
  }

  Widget _blocoImagem() {
    final caminho = _imagemPath;
    final existe = caminho != null && File(caminho).existsSync();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto do show ou do ingresso',
            style: TextStyle(color: AppCores.textoPrimario, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (existe)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(File(caminho), fit: BoxFit.cover),
              ),
            ),
          if (existe) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _salvando ? null : () => _escolherImagem(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _salvando ? null : () => _escolherImagem(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Câmera'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
