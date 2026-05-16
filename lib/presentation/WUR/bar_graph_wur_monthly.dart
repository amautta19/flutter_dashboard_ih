import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarGraphWurMonthly extends StatefulWidget {
  final List<dynamic> allData;
  final bool umbralInverso;
  final String unidadM;
  final String titleM;
  final double widthGraph;
  final int maxLabel;

  const BarGraphWurMonthly({
    super.key,
    required this.allData,
    this.umbralInverso = false,
    this.unidadM = '',
    this.titleM = 'Consumo Agua (m³)',
    this.widthGraph = 0.50,
    this.maxLabel = 14,
  });

  @override
  State<BarGraphWurMonthly> createState() => _BarGraphWurMonthlyState();
}

class _BarGraphWurMonthlyState extends State<BarGraphWurMonthly> {

  late List<dynamic> _sortedData;

  @override
  void initState() {
    super.initState();
    _prepararDatos();
  }

  @override
  void didUpdateWidget(covariant BarGraphWurMonthly oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _prepararDatos();
    }
  }

  void _prepararDatos() {
    _sortedData = List.from(widget.allData);
    _sortedData.sort((a, b) {
      try {
        DateTime fechaA = DateTime.parse(a['mes_label']);
        DateTime fechaB = DateTime.parse(b['mes_label']);
        return fechaA.compareTo(fechaB);
      } catch (e) {
        return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String selectedFilter = context.watch<FilterElementProvider>().getElement;
    final umbralesProvider = context.watch<UmbralesProvider>();

    final umbralFila = umbralesProvider.tablaUmbrales.firstWhere(
      (u) => selectedFilter.contains(u['argumento']),
      orElse: () => {},
    );

    final double valorReferencia = (umbralFila['umbral'] as num).toDouble();
    final String umbralLimite = 'Umbral Técnico: ${valorReferencia.toStringAsFixed(1)} ${widget.unidadM}';

    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.35,
      width: windowSize.width * widget.widthGraph,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorDefaults.darkBgCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorDefaults.darkBgBorder, width: 1),
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
                '${widget.titleM} : $selectedFilter',
                color: ColorDefaults.darkCyan,
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
                    fontSize: 13,
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
                header: 'WUR Mensual',
                color: ColorDefaults.darkBgHeader,
                textStyle: const TextStyle(
                  color: ColorDefaults.darkTextPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                activationMode: ActivationMode.singleTap,
                duration: 300,
              ),
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: widget.maxLabel,
                autoScrollingMode: AutoScrollingMode.end,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
                labelStyle: const TextStyle(color: ColorDefaults.darkTextMuted, fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                rangePadding: ChartRangePadding.additional,
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: ColorDefaults.darkGridLine,
                ),
                axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
                labelStyle: const TextStyle(color: ColorDefaults.darkTextMuted, fontSize: 10),
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
                  xValueMapper: (data, _) => data['mes_label']?.toString() ?? '',
                  yValueMapper: (data, _) => data['wur_mensual'] ?? 0,
                  pointColorMapper: (data, _) {
                    final valor = (data['wur_mensual'] ?? 0).toDouble();
                    if (!widget.umbralInverso) {
                      return valor > valorReferencia ? ColorDefaults.darkBarBad : ColorDefaults.darkBarGood;
                    } else {
                      return valor < valorReferencia ? ColorDefaults.darkBarBad : ColorDefaults.darkBarGood;
                    }
                  },
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    borderRadius: 4,
                    color: ColorDefaults.darkBgHeader.withOpacity(0.85),
                    textStyle: const TextStyle(
                      fontSize: 10,
                      color: ColorDefaults.darkTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Línea de tendencia
                LineSeries<dynamic, String>(
                  key: ValueKey('line_$selectedFilter'),
                  name: 'Evolución',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['mes_label']?.toString() ?? '',
                  yValueMapper: (data, _) => data['wur_mensual'] ?? 0,
                  color: ColorDefaults.darkCyan,
                  width: 2,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 5,
                    width: 5,
                    shape: DataMarkerType.circle,
                    color: ColorDefaults.darkCyan,
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