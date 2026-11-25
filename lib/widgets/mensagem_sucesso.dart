import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MensagemSucesso extends StatelessWidget {
  final String mensagem;

  const MensagemSucesso({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppCores.sucesso.withValues(alpha: 0.12),
        border: Border.all(color: AppCores.sucesso.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: AppCores.sucesso),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(color: AppCores.sucesso, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
