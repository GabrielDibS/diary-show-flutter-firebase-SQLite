import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exceptions.dart';

class ApiService {
  static const String _baseUrl = 'www.theaudiodb.com';
  static const String _chaveGratuita = '123';
  static const Duration _timeout = Duration(seconds: 15);

  Uri _montaUri(String endpoint, Map<String, String> query) {
    return Uri.https(_baseUrl, '/api/v1/json/$_chaveGratuita/$endpoint', query);
  }

  Future<Map<String, dynamic>> buscaArtista(String nome) {
    final uri = _montaUri('search.php', {'s': nome.trim()});
    return _getPrimeiroItem(uri, 'artists', nome);
  }

  Future<Map<String, dynamic>> musicaMaisTocada(String nome) async {
    final artista = await buscaArtista(nome);
    final uri = _montaUri('track-top10.php', {'s': nome.trim()});
    final faixa = await _getPrimeiroItem(uri, 'track', nome);
    return {
      '_imagemArtista': artista['strArtistThumb'],
      ...faixa,
    };
  }

  Future<Map<String, dynamic>> albunsDoArtista(String nome) async {
    final artista = await buscaArtista(nome);
    final id = artista['idArtist']?.toString();
    if (id == null || id.isEmpty) {
      throw ApiException('Não foi possível identificar o artista "$nome".');
    }

    Map<String, dynamic>? album;

    // 1) tenta achar o mais recente pela discografia
    try {
      final disc = await _getBruto(
        _montaUri('discography.php', {'s': nome.trim()}),
      );
      final lista = disc['album'];
      if (lista is List) {
        final comAno = lista
            .whereType<Map<String, dynamic>>()
            .where((a) => int.tryParse('${a['intYearReleased']}') != null)
            .toList()
          ..sort((a, b) => int.parse('${b['intYearReleased']}')
              .compareTo(int.parse('${a['intYearReleased']}')));

        if (comAno.isNotEmpty) {
          // 2) busca os detalhes (com capa) desse álbum
          final det = await _getBruto(_montaUri('searchalbum.php', {
            's': nome.trim(),
            'a': comAno.first['strAlbum'].toString(),
          }));
          final l = det['album'];
          if (l is List && l.isNotEmpty && l.first is Map<String, dynamic>) {
            album = l.first as Map<String, dynamic>;
          }
        }
      }
    } catch (_) {}

    // 3) fallback: o que o album.php devolver
    if (album == null) {
      final resposta = await _getBruto(_montaUri('album.php', {'i': id}));
      final lista = resposta['album'];
      if (lista == null || lista is! List || lista.isEmpty) {
        throw ApiException('Nenhum álbum encontrado para "$nome".');
      }
      album = lista.whereType<Map<String, dynamic>>().first;
    }

    return {
      'strArtist': artista['strArtist'],
      'strArtistThumb': artista['strArtistThumb'],
      'albuns': [album],
    };
  }

  Future<Map<String, dynamic>> _getPrimeiroItem(
    Uri uri,
    String chave,
    String termoBuscado, {
    String? mensagemVazio,
  }) async {
    final decodificado = await _getBruto(uri);
    final lista = decodificado[chave];
    if (lista == null || lista is! List || lista.isEmpty) {
      throw ApiException(mensagemVazio ?? 'Nenhum resultado encontrado para "$termoBuscado".');
    }
    final primeiro = lista.first;
    if (primeiro is! Map<String, dynamic>) {
      throw const ApiException('A API retornou dados em um formato inesperado.');
    }
    return primeiro;
  }

  Future<Map<String, dynamic>> _getBruto(Uri uri) async {
    http.Response response;
    try {
      response = await http.get(uri).timeout(_timeout);
    } on SocketException {
      throw const ConnectionException();
    } on TimeoutException {
      throw const ConnectionException(
        'A consulta demorou demais para responder. Verifique sua conexão e tente novamente.',
      );
    } on HttpException {
      throw const ConnectionException();
    }

    switch (response.statusCode) {
      case 200:
        break;
      case 429:
        throw const ApiException(
          'Limite de requisições atingido (máximo de 30 por minuto no plano gratuito). Aguarde um pouco e tente novamente.',
          statusCode: 429,
        );
      case 404:
        throw const ApiException('Nenhum resultado encontrado para essa consulta.', statusCode: 404);
      default:
        if (response.statusCode >= 500) {
          throw ApiException(
            'O servidor da API está indisponível no momento (código ${response.statusCode}). Tente novamente mais tarde.',
            statusCode: response.statusCode,
          );
        }
        throw ApiException(
          'Erro ao consultar a API (código ${response.statusCode}).',
          statusCode: response.statusCode,
        );
    }

    if (response.body.trim().isEmpty) {
      throw const ApiException('A API retornou uma resposta vazia.');
    }

    dynamic decodificado;
    try {
      decodificado = json.decode(response.body);
    } on FormatException {
      throw const ApiException('A API retornou dados em um formato inesperado.');
    }

    if (decodificado is! Map<String, dynamic>) {
      throw const ApiException('A API retornou dados em um formato inesperado.');
    }
    return decodificado;
  }
}
