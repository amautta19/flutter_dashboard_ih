import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarGraphDiaryMulti extends StatefulWidget {
  final List<dynamic> allData;
  const BarGraphDiaryMulti({super.key, required this.allData});

  @override
  State<BarGraphDiaryMulti> createState() => _BarGraphDiaryMultiState();
}

class _BarGraphDiaryMultiState extends State<BarGraphDiaryMulti> {
  late List<dynamic> _fullRangeData;
  late TooltipBehavior _tooltipUpper;
  late TooltipBehavior _tooltipLower;
  late TooltipBehavior _tooltipTeorico;

  // Colores por línea — consistentes en los 3 gráficos
  static const Color _colorLinea1  = Colors.green;
  static const Color _colorLinea2  = Colors.blue;  // cyan más oscuro
  static const Color _colorLinea10 = Colors.orange; // naranja
  static const Color _colorLinea11 = Colors.red; // rojo

  @override
  void initState() {
    super.initState();
    _generarRangoCompleto();

    _tooltipUpper = TooltipBehavior(
      enable: true,
      header: '',
      format: 'series.name: point.y m³',
      canShowMarker: false,
      color: ColorDefaults.darkBgHeader,
      textStyle: const TextStyle(
        color: ColorDefaults.darkTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );

    _tooltipLower = TooltipBehavior(
      enable: true,
      header: '',
      format: 'series.name: point.y min',
      canShowMarker: true,
      color: ColorDefaults.darkBgHeader,
      textStyle: const TextStyle(
        color: ColorDefaults.darkTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );

    _tooltipTeorico = TooltipBehavior(
      enable: true,
      header: '',
      format: 'series.name: point.y m³',
      canShowMarker: true,
      color: ColorDefaults.darkBgHeader,
      textStyle: const TextStyle(
        color: ColorDefaults.darkTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant BarGraphDiaryMulti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _generarRangoCompleto();
    }
  }

  void _generarRangoCompleto() {
    List<dynamic> fullDay = [];
    DateTime ahora = DateTime.now();
    DateTime inicioTurno = DateTime(ahora.year, ahora.month, ahora.day, 8, 0);

    for (int i = 0; i < 24; i++) {
      DateTime horaActual = inicioTurno.add(Duration(hours: i));
      String label = DateFormat('HH:mm').format(horaActual);

      dynamic existingData;
      try {
        existingData = widget.allData.firstWhere(
          (d) => _formatTime(d['_time_lima']) == label,
        );
      } catch (e) {
        existingData = null;
      }

      if (existingData != null) {
        fullDay.add(existingData);
      } else {
        fullDay.add({
          '_time_lima': horaActual.toIso8601String(),
          'Lavadoras': 0,
          'linea1': 0,
          'linea2': 0,
          'linea10': 0,
          'linea11': 0,
        });
      }
    }
    setState(() {
      _fullRangeData = fullDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.90,
      width: double.infinity,
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
          GlobalText(
            'Consumo Total Lavadoras vs Tiempo Efectivo',
            color: ColorDefaults.darkCyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 5),

          // ── Gráfico superior — Consumo total ─────────────────
          Expanded(
            flex: 3,
            child: SfCartesianChart(
              backgroundColor: Colors.transparent,
              plotAreaBackgroundColor: Colors.transparent,
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: ColorDefaults.darkTextMuted,
                ),
              ),
              tooltipBehavior: _tooltipUpper,
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                isVisible: true,
                labelStyle: const TextStyle(fontSize: 0),
                autoScrollingDelta: 24,
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: ColorDefaults.darkGridLine,
                  dashArray: [5, 5],
                ),
                axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(fontSize: 0),
                minimum: 0,
                maximum: 60,
                axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: ColorDefaults.darkGridLine,
                ),
                title: AxisTitle(
                  text: 'Consumo Total',
                  textStyle: const TextStyle(
                    fontSize: 13,
                    color: ColorDefaults.darkCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              series: <CartesianSeries<dynamic, String>>[
                _buildColumnSeries('Lavadoras Total', 'Lavadoras', ColorDefaults.primaryBlue),
                _buildColumnSeries('Consumo Teórico', 'lavadoras_teorico', ColorDefaults.darkCyan),
              ],
            ),
          ),

          // ── Gráfico medio — Consumo teórico por línea ────────
          Expanded(
            flex: 3,
            child: SfCartesianChart(
              backgroundColor: Colors.transparent,
              plotAreaBackgroundColor: Colors.transparent,
              tooltipBehavior: _tooltipTeorico,
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: ColorDefaults.darkTextMuted,
                ),
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                interval: 1,
                autoScrollingDelta: 24,
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: ColorDefaults.darkGridLine,
                  dashArray: [5, 5],
                ),
                axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
                labelStyle: const TextStyle(fontSize: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 10,
                labelStyle: const TextStyle(fontSize: 0),
                axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: ColorDefaults.darkGridLine,
                ),
                title: AxisTitle(
                  text: 'Consumo Teórico',
                  textStyle: const TextStyle(
                    fontSize: 13,
                    color: ColorDefaults.darkCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              series: <CartesianSeries<dynamic, String>>[
                ..._buildGroupedProgress('Línea 1',  'lavadora_l1_teorico',  _colorLinea1),
                ..._buildGroupedProgress('Línea 2',  'lavadora_l2_teorico',  _colorLinea2),
                ..._buildGroupedProgress('Línea 10', 'lavadora_l10_teorico', _colorLinea10),
                ..._buildGroupedProgress('Línea 11', 'lavadora_l11_teorico', _colorLinea11),
              ],
            ),
          ),

          // ── Gráfico inferior — Minutos efectivos por línea ───
          Expanded(
            flex: 4,
            child: SfCartesianChart(
              backgroundColor: Colors.transparent,
              plotAreaBackgroundColor: Colors.transparent,
              tooltipBehavior: _tooltipLower,
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: ColorDefaults.darkTextMuted,
                ),
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                interval: 1,
                autoScrollingDelta: 24,
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: ColorDefaults.darkGridLine,
                  dashArray: [5, 5],
                ),
                axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
                labelStyle: const TextStyle(
                  color: ColorDefaults.darkTextMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 240,
                interval: 60,
                labelStyle: const TextStyle(fontSize: 0),
                axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: ColorDefaults.darkGridLine,
                ),
                title: AxisTitle(
                  text: 'Minutos Efectivos por Línea',
                  textStyle: const TextStyle(
                    fontSize: 13,
                    color: ColorDefaults.darkCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              series: <CartesianSeries<dynamic, String>>[
                ..._buildFixedCenterProgress('Línea 1',  'linea1',  _colorLinea1,  30),
                ..._buildFixedCenterProgress('Línea 2',  'linea2',  _colorLinea2,  90),
                ..._buildFixedCenterProgress('Línea 10', 'linea10', _colorLinea10, 150),
                ..._buildFixedCenterProgress('Línea 11', 'linea11', _colorLinea11, 210),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Series helpers ───────────────────────────────────────────

  List<CartesianSeries<dynamic, String>> _buildGroupedProgress(
      String name, String key, Color color) {
    return [
      ColumnSeries<dynamic, String>(
        name: name,
        dataSource: _fullRangeData,
        xValueMapper: (data, _) => _formatTime(data['_time_lima']),
        yValueMapper: (data, _) => data[key] ?? 0,
        color: color,
        enableTooltip: true,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(
            fontSize: 10,
            color: ColorDefaults.darkTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }

  List<CartesianSeries<dynamic, String>> _buildFixedCenterProgress(
      String name, String key, Color color, double fixedCenterY) {
    return [
      StackedColumnSeries<dynamic, String>(
        name: name,
        enableTooltip: true,
        dataSource: _fullRangeData,
        xValueMapper: (data, _) => _formatTime(data['_time_lima']),
        yValueMapper: (data, _) => data[key] ?? 0,
        color: color,
        width: 0.8,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      ),
      StackedColumnSeries<dynamic, String>(
        name: '$name (Resto)',
        enableTooltip: false,
        dataSource: _fullRangeData,
        xValueMapper: (data, _) => _formatTime(data['_time_lima']),
        yValueMapper: (data, _) {
          double valor = double.tryParse((data[key] ?? 0).toString()) ?? 0;
          return (60 - valor) > 0 ? (60 - valor) : 0;
        },
        color: color.withOpacity(0.12),
        width: 0.8,
        isVisibleInLegend: false,
        borderColor: color.withOpacity(0.3),
        borderWidth: 1,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      ),
      ScatterSeries<dynamic, String>(
        dataSource: _fullRangeData,
        enableTooltip: false,
        xValueMapper: (data, _) => _formatTime(data['_time_lima']),
        yValueMapper: (data, _) => fixedCenterY,
        color: Colors.transparent,
        markerSettings: const MarkerSettings(isVisible: false),
        isVisibleInLegend: false,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          showZeroValue: true,
          builder: (dynamic data, dynamic point, dynamic series,
              int pointIndex, int seriesIndex) {
            final double realValue =
                double.tryParse((data[key] ?? 0).toString()) ?? 0;
            return Text(
              realValue.toInt().toString(),
              style: const TextStyle(
                fontSize: 12,
                color: ColorDefaults.darkTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    ];
  }

  ColumnSeries<dynamic, String> _buildColumnSeries(
      String name, String key, Color color) {
    return ColumnSeries<dynamic, String>(
      name: name,
      enableTooltip: true,
      dataSource: _fullRangeData,
      xValueMapper: (data, _) => _formatTime(data['_time_lima']),
      yValueMapper: (data, _) => data[key] ?? 0,
      color: color,
      width: 0.8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      dataLabelSettings: const DataLabelSettings(
        isVisible: true,
        showZeroValue: false,
        labelAlignment: ChartDataLabelAlignment.outer,
        textStyle: TextStyle(
          fontSize: 12,
          color: ColorDefaults.darkTextMuted,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(dynamic timeData) {
    final String fullTime = timeData?.toString() ?? '';
    try {
      DateTime dt = DateTime.parse(fullTime);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return fullTime;
    }
  }
}