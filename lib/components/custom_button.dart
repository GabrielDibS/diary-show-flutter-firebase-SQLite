import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;
  final IconData? icone;

  const CustomButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: carregando ? null : onPressed,
      child: carregando
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(texto),
              ],
            ),
    );
  }
}
