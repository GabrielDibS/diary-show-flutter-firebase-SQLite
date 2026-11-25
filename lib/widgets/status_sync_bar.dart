import 'package:flutter/material.dart';

import '../services/sync_service.dart';
import '../theme/app_theme.dart';

class StatusSyncBar extends StatelessWidget {
  const StatusSyncBar({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = SyncService.instance;

    return ValueListenableBuilder<bool>(
      valueListenable: sync.online,
      builder: (context, online, _) {
        return ValueListenableBuilder<int>(
          valueListenable: sync.pendentes,
          builder: (context, pendentes, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: sync.sincronizando,
              builder: (context, sincronizando, _) {
                final cor = online ? AppCores.sucesso : AppCores.destaque;
                final textoPendentes = pendentes == 0
                    ? 'Tudo sincronizado'
                    : '$pendentes registro${pendentes == 1 ? '' : 's'} pendente${pendentes == 1 ? '' : 's'}';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppCores.superficie,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined, color: cor, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              online ? 'Online' : 'Offline',
                              style: TextStyle(color: cor, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(
                              sincronizando ? 'Sincronizando...' : textoPendentes,
                              style: const TextStyle(color: AppCores.textoSecundario, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (sincronizando)
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: AppCores.primariaClara),
                        )
                      else if (online && pendentes > 0)
                        TextButton(
                          onPressed: sync.sincronizar,
                          child: const Text('Sincronizar'),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
