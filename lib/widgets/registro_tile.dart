import 'package:flutter/material.dart';

import '../models/registro_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatadores.dart';

class RegistroTile extends StatelessWidget {
  final Registro registro;
  final VoidCallback onTap;

  const RegistroTile({super.key, required this.registro, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pendente = !registro.synced;
    final subtitulo = [
      if (registro.artista.trim().isNotEmpty) registro.artista,
      if (registro.local.trim().isNotEmpty) registro.local,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppCores.primaria.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  formatarDiaMes(registro.dataEvento),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppCores.primariaClara,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registro.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppCores.textoPrimario,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitulo.isNotEmpty)
                      Text(
                        subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppCores.textoSecundario, fontSize: 13),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: pendente ? 'Pendente de envio' : 'Sincronizado',
                child: Icon(
                  pendente ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
                  color: pendente ? AppCores.destaque : AppCores.sucesso,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
