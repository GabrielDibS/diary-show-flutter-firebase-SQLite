class Validators {
  Validators._();

  static String? campoObrigatorio(
    String? valor, {
    String mensagem = 'Este campo é obrigatório.',
  }) {
    if (valor == null || valor.trim().isEmpty) {
      return mensagem;
    }
    return null;
  }

  static String? nomeArtista(String? valor) {
    final obrigatorio =
        campoObrigatorio(valor, mensagem: 'Informe o nome de um artista.');
    if (obrigatorio != null) return obrigatorio;

    if (valor!.trim().length < 2) {
      return 'Digite pelo menos 2 caracteres.';
    }
    return null;
  }

  static String? nomeCompleto(String? valor) {
    final obrigatorio =
        campoObrigatorio(valor, mensagem: 'Informe seu nome completo.');
    if (obrigatorio != null) return obrigatorio;

    final partes = valor!.trim().split(RegExp(r'\s+'));
    if (partes.length < 2) {
      return 'Informe nome e sobrenome.';
    }
    return null;
  }

  static String? email(String? valor) {
    final obrigatorio = campoObrigatorio(valor, mensagem: 'Informe seu e-mail.');
    if (obrigatorio != null) return obrigatorio;

    final regex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
    if (!regex.hasMatch(valor!.trim())) {
      return 'Digite um e-mail válido (ex: nome@dominio.com).';
    }
    return null;
  }

  static String? senha(String? valor) {
    final obrigatorio = campoObrigatorio(valor, mensagem: 'Informe sua senha.');
    if (obrigatorio != null) return obrigatorio;

    if (valor!.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  static String? confirmarSenha(String? valor, String senhaOriginal) {
    final obrigatorio =
        campoObrigatorio(valor, mensagem: 'Confirme sua senha.');
    if (obrigatorio != null) return obrigatorio;

    if (valor != senhaOriginal) {
      return 'As senhas não conferem.';
    }
    return null;
  }
}
