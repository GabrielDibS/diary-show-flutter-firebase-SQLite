import 'package:intl/intl.dart';

String formatarData(DateTime data) {
  return DateFormat('dd/MM/yyyy', 'pt_BR').format(data);
}

String formatarDiaMes(DateTime data) {
  return DateFormat('dd MMM', 'pt_BR').format(data).toUpperCase();
}

String formatarDataExtenso(DateTime data) {
  return DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR').format(data);
}

String formatarCoordenada(double valor) {
  return valor.toStringAsFixed(6);
}
