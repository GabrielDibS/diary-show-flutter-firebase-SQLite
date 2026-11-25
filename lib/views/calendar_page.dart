import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/registro_model.dart';
import '../services/registro_firebase.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatadores.dart';
import '../widgets/carregando_view.dart';
import '../widgets/mensagem_erro.dart';
import '../widgets/registro_tile.dart';
import '../widgets/status_sync_bar.dart';
import 'details_page.dart';
import 'registro_form_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _repo = RegistroRepository();
  final _sync = SyncService.instance;

  DateTime _diaFocado = DateTime.now();
  DateTime? _diaSelecionado = DateTime.now();
  CalendarFormat _formato = CalendarFormat.month;

  Map<String, List<Registro>> _registrosPorDia = {};
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
    _sync.versao.addListener(_carregar);
  }

  @override
  void dispose() {
    _sync.versao.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final resultado = await _repo.listar();
      final mapa = <String, List<Registro>>{};
      for (final registro in resultado.registros) {
        mapa.putIfAbsent(registro.chaveDoEvento, () => []).add(registro);
      }
      if (!mounted) return;
      setState(() {
        _registrosPorDia = mapa;
        _erro = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar os registros.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<Registro> _eventosDoDia(DateTime dia) {
    return _registrosPorDia[Registro.chaveDia(dia)] ?? const [];
  }

  Future<void> _novoNaData() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroFormPage(dataInicial: _diaSelecionado ?? DateTime.now()),
      ),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _abrirDetalhes(Registro registro) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsPage(registro: registro)),
    );
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final selecionado = _diaSelecionado;
    final doDia = selecionado == null ? <Registro>[] : _eventosDoDia(selecionado);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Calendário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoNaData,
        icon: const Icon(Icons.add),
        label: const Text('Show nesta data'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const StatusSyncBar(),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppCores.superficie,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TableCalendar<Registro>(
                      locale: 'pt_BR',
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _diaFocado,
                      calendarFormat: _formato,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mês',
                        CalendarFormat.twoWeeks: '2 semanas',
                        CalendarFormat.week: 'Semana',
                      },
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      selectedDayPredicate: (dia) => isSameDay(_diaSelecionado, dia),
                      eventLoader: _eventosDoDia,
                      onDaySelected: (selecionadoDia, focadoDia) {
                        setState(() {
                          _diaSelecionado = selecionadoDia;
                          _diaFocado = focadoDia;
                        });
                      },
                      onFormatChanged: (formato) => setState(() => _formato = formato),
                      onPageChanged: (focadoDia) => _diaFocado = focadoDia,
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        titleTextStyle: const TextStyle(
                          color: AppCores.textoPrimario,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        formatButtonTextStyle: const TextStyle(color: AppCores.primariaClara, fontSize: 13),
                        formatButtonDecoration: BoxDecoration(
                          border: Border.all(color: AppCores.primaria.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: AppCores.textoPrimario),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: AppCores.textoPrimario),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: AppCores.textoSecundario, fontSize: 12),
                        weekendStyle: TextStyle(color: AppCores.textoSecundario, fontSize: 12),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: const TextStyle(color: AppCores.textoPrimario),
                        weekendTextStyle: const TextStyle(color: AppCores.textoPrimario),
                        outsideTextStyle: const TextStyle(color: Color(0xFF5B6075)),
                        todayTextStyle: const TextStyle(color: AppCores.textoPrimario),
                        selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        todayDecoration: BoxDecoration(
                          color: AppCores.primaria.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppCores.primaria,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppCores.destaque,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    selecionado == null ? 'Selecione uma data' : formatarDataExtenso(selecionado),
                    style: const TextStyle(
                      color: AppCores.textoPrimario,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_carregando)
                    const CarregandoView(mensagem: 'Carregando eventos...')
                  else if (_erro != null)
                    MensagemErro(mensagem: _erro!)
                  else if (doDia.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Nenhum show nesta data.',
                        style: TextStyle(color: AppCores.textoSecundario),
                      ),
                    )
                  else
                    ...doDia.map(
                      (registro) => RegistroTile(
                        registro: registro,
                        onTap: () => _abrirDetalhes(registro),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
