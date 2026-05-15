import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WurBarGraphDiary extends StatefulWidget {
  final List<dynamic> allData;
  final bool umbralInverso;
  final String unidadM;
  final String titleM;
  final double widthGraph;
  final int maxLabel;

  const WurBarGraphDiary({
    super.key,
    required this.allData,
    this.umbralInverso = false,
    this.unidadM = 'm³',
    this.titleM = 'Consumo Agua (m³)',
    this.widthGraph = 0.60,
    this.maxLabel = 14,
  });

  @override
  State<WurBarGraphDiary> createState() => _WurBarGraphDiaryState();
}

class _WurBarGraphDiaryState extends State<WurBarGraphDiary> {
  late List<dynamic> _sortedData;

  // Paleta de colores del tema oscuro
  static const Color _bgCard       = Color(0xFF1E1E2E);
  static const Color _bgCardBorder = Color(0xFF2E2E4E);
  static const Color _bgTooltip    = Color(0xFF2A2A3E);
  static const Color _cyan         = Color(0xFF00E5FF);
  static const Color _textPrimary  = Colors.white;
  static const Color _textMuted    = Color(0xFFB0B0C8);
  static const Color _gridLine     = Color(0x1FFFFFFF); // blanco 12% opacidad
  static const Color _axisLine     = Color(0x33FFFFFF); // blanco 20% opacidad
  static const Color _barGood      = Color(0xFF4CAF50); // verde
  static const Color _barBad       = Color(0xFFE53935); // rojo
  static const Color _barInvGood   = Color(0xFF00E5FF); // cyan para umbral inverso

  @override
  void initState() {
    super.initState();
    _prepararDatos();
  }

  @override
  void didUpdateWidget(covariant WurBarGraphDiary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _prepararDatos();
    }
  }

  void _prepararDatos() {
    _sortedData = List.from(widget.allData);
    _sortedData.sort((a, b) {
      try {
        DateTime fechaA = DateTime.parse(a['fecha_operativa']);
        DateTime fechaB = DateTime.parse(b['fecha_operativa']);
        return fechaA.compareTo(fechaB);
      } catch (e) {
        return 0;
      }
    });
  }

  double _calcularPromedio(String column) {
    if (_sortedData.isEmpty) return 0;
    double suma = 0;
    int cont = 0;
    for (var item in _sortedData) {
      final valor = (item[column] ?? 0).toDouble();
      if (valor > 0) {
        suma += valor;
        cont++;
      }
    }
    return cont > 0 ? suma / cont : 0;
  }

  @override
  Widget build(BuildContext context) {
    final String selectedFilter = context.watch<FilterElementProvider>().getElement;
    final umbralesProvider = context.watch<UmbralesProvider>();

    final umbralFila = umbralesProvider.tablaUmbrales.firstWhere(
      (u) => selectedFilter.contains(u['argumento']),
      orElse: () => {},
    );

    double valorReferencia;
    String umbralLimite;

    if (umbralFila.isNotEmpty && umbralFila['umbral'] != null) {
      valorReferencia = (umbralFila['umbral'] as num).toDouble();
      umbralLimite = 'Umbral Técnico: ${valorReferencia.toStringAsFixed(1)} ${widget.unidadM}';
    } else {
      valorReferencia = _calcularPromedio(selectedFilter);
      umbralLimite = 'Promedio: ${valorReferencia.toStringAsFixed(1)} ${widget.unidadM}';
    }

    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.42,
      width: windowSize.width * widget.widthGraph,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _bgCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlobalText(
                widget.titleM,
                color: _cyan,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GlobalText(
                    umbralLimite,
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Gráfico ─────────────────────────────────────────────
          Expanded(
            child: SfCartesianChart(
              key: ValueKey('chart_${selectedFilter}_$valorReferencia'),
              backgroundColor: Colors.transparent,
              plotAreaBackgroundColor: Colors.transparent,
              zoomPanBehavior: ZoomPanBehavior(
                enablePanning: true,
                zoomMode: ZoomMode.x,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: 'WUR',
                color: _bgTooltip,
                textStyle: const TextStyle(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                activationMode: ActivationMode.singleTap,
                duration: 500,
              ),
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: widget.maxLabel,
                autoScrollingMode: AutoScrollingMode.end,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(color: _axisLine, width: 1),
                labelStyle: const TextStyle(color: _textMuted, fontSize: 12),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 3.2,
                rangePadding: ChartRangePadding.additional,
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: _gridLine,
                ),
                axisLine: const AxisLine(color: _axisLine, width: 1),
                labelStyle: const TextStyle(color: _textMuted, fontSize: 10),
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: valorReferencia,
                    end: valorReferencia,
                    borderWidth: 2,
                    borderColor: Colors.orangeAccent,
                    dashArray: <double>[6, 6],
                  ),
                ],
              ),
              series: <CartesianSeries<dynamic, String>>[
                // Barras
                ColumnSeries<dynamic, String>(
                  key: ValueKey('bars_$selectedFilter'),
                  name: 'WUR',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) =>
                      data['fecha_operativa']?.toString() ?? '',
                  yValueMapper: (data, _) => data[selectedFilter] ?? 0,
                  pointColorMapper: (data, _) {
                    final valor = (data[selectedFilter] ?? 0).toDouble();
                    if (!widget.umbralInverso) {
                      return valor > valorReferencia ? _barBad : _barGood;
                    } else {
                      return valor < valorReferencia ? _barBad : _barInvGood;
                    }
                  },
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    borderRadius: 4,
                    color: _bgTooltip.withOpacity(0.85),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: _textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Línea de tendencia
                LineSeries<dynamic, String>(
                  key: ValueKey('line_$selectedFilter'),
                  name: 'Evolución',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) =>
                      data['fecha_operativa']?.toString() ?? '',
                  yValueMapper: (data, _) => data[selectedFilter] ?? 0,
                  color: _cyan,
                  width: 2,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 5,
                    width: 5,
                    shape: DataMarkerType.circle,
                    color: _cyan,
                    borderColor: Colors.white,
                    borderWidth: 1,
                  ),
                  // Sin data labels en la línea para no duplicar con las barras
                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                  animationDuration: 500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}