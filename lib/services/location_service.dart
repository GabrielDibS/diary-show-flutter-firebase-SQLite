import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocalizacaoException implements Exception {
  final String message;
  final bool sugerirConfiguracoes;

  const LocalizacaoException(this.message, {this.sugerirConfiguracoes = false});

  @override
  String toString() => message;
}

class LocationService {
  Future<bool> permissaoPendente() async {
    final permissao = await Geolocator.checkPermission();
    return permissao == LocationPermission.denied;
  }

  Future<Position> obterPosicaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw const LocalizacaoException(
        'O serviço de localização (GPS) está desativado. Ative-o nas configurações do aparelho.',
      );
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied) {
      throw const LocalizacaoException('Permissão de localização negada.');
    }
    if (permissao == LocationPermission.deniedForever) {
      throw const LocalizacaoException(
        'A permissão de localização foi negada permanentemente. Libere-a nas configurações do aplicativo.',
        sugerirConfiguracoes: true,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      throw const LocalizacaoException(
        'Não foi possível obter a localização a tempo. Tente novamente em um local aberto.',
      );
    }
  }

  Future<void> abrirConfiguracoesDoApp() async {
    await Geolocator.openAppSettings();
  }
}
