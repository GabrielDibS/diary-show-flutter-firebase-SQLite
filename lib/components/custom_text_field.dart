import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icone;
  final bool senha;
  final int maxLinhas;
  final TextInputType? teclado;
  final TextInputAction? acaoTeclado;
  final String? Function(String?)? validator;
  final bool habilitado;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icone,
    this.senha = false,
    this.maxLinhas = 1,
    this.teclado,
    this.acaoTeclado,
    this.validator,
    this.habilitado = true,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _ocultar = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.habilitado,
      obscureText: widget.senha && _ocultar,
      maxLines: widget.senha ? 1 : widget.maxLinhas,
      keyboardType: widget.teclado,
      textInputAction: widget.acaoTeclado,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.icone == null ? null : Icon(widget.icone),
        suffixIcon: widget.senha
            ? IconButton(
                icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _ocultar = !_ocultar),
              )
            : null,
      ),
    );
  }
}
