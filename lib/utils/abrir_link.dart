import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> abrirLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  var abriu = false;
  try {
    abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    abriu = false;
  }

  if (!abriu && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o link.')),
    );
  }
}
