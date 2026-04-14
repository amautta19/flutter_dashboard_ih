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

  @override
  void initState() {
    super.initState();
    _generarRangoCompleto();
    
    _tooltipUpper = TooltipBehavior(
      enable: true, 
      header: '',
      format: 'Consumo Total Lavadoras: point.y m³',
      canShowMarker: false
    );
    
    _tooltipLower = TooltipBehavior(
      enable: true,
      header: '', 
      format: 'series.name: point.y min',
      canShowMarker: true
    );
    _tooltipTeorico = TooltipBehavior(
      enable: true,
      header: '',
      format: 'series.name: point.y m³',
      canShowMarker: true
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
    // Inicio del turno: Hoy a las 08:00 AM
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: ColorDefaults.whitePrimary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: ColorDefaults.whitePrimary)),
      child: Column(
        children: [
          GlobalText(
            'Consumo Total vs Tiempo por Línea',
            color: ColorDefaults.primaryBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          
          // --- GRÁFICA SUPERIOR ---
          Expanded(
            flex: 3,
            child: SfCartesianChart(
              tooltipBehavior: _tooltipUpper,
              title: ChartTitle(
                  text: 'Consumo Total Lavadoras (m³)', 
                  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                isVisible: true,
                labelStyle: const TextStyle(fontSize: 0),
                autoScrollingDelta: 24,
                majorGridLines: const MajorGridLines(width: 1, color: Colors.black, dashArray: [5, 5]),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(fontSize: 0),
                minimum: 0,
                maximum: 60,
                title: AxisTitle(
                  text: 'Consumo Total Lavadoras',
                  textStyle: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold)
                ),
              ),
              series: <CartesianSeries<dynamic, String>>[
                _buildColumnSeries('Lavadoras', 'Lavadoras', ColorDefaults.primaryBlue)
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: SfCartesianChart(
              tooltipBehavior: _tooltipTeorico,
              legend: const Legend(
                  isVisible: true, 
                  position: LegendPosition.bottom, 
                  textStyle: TextStyle(fontSize: 12)
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                interval: 1,
                autoScrollingDelta: 24, // Reducimos para que se vean bien las 4 columnas por hora
                majorGridLines: const MajorGridLines(width: 1, color: Colors.black, dashArray: [5,5]),
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Consumo Teórico',
                  textStyle: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold)
                ),
                minimum: 0,
                maximum: 10, // AHORA EL MÁXIMO ES 60 porque ya no se apilan
                // interval: 10,
                labelStyle: const TextStyle(fontSize: 10),
              ),
              series: <CartesianSeries<dynamic, String>>[
                // Llamamos a cada línea. Cada una genera su barra y su fondo.
                ..._buildGroupedProgress('Línea 1', 'lavadora_l1_teorico', ColorDefaults.primaryBlue),
                ..._buildGroupedProgress('Línea 2', 'lavadora_l2_teorico', Colors.teal),
                ..._buildGroupedProgress('Línea 10', 'lavadora_l10_teorico', Colors.orangeAccent),
                ..._buildGroupedProgress('Línea 11', 'lavadora_l11_teorico', Colors.redAccent),
              ],
            ),
          ),
          // --- GRÁFICA INFERIOR ---
          Expanded(
            flex: 4,
            child: SfCartesianChart(
              tooltipBehavior: _tooltipLower,
              legend: const Legend(
                  isVisible: true, 
                  position: LegendPosition.bottom, 
                  textStyle: TextStyle(fontSize: 12)
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                interval: 1,
                autoScrollingDelta: 24, 
                majorGridLines: const MajorGridLines(width: 1, color: Colors.black, dashArray: [5,5]),
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Minutos Efectivos por Línea',
                  textStyle: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold)
                ),
                minimum: 0,
                maximum: 240, 
                interval: 60,
                labelStyle: const TextStyle(fontSize: 0),
              ),
              series: <CartesianSeries<dynamic, String>>[
                ..._buildFixedCenterProgress('Línea 1', 'linea1', ColorDefaults.primaryBlue, 30),
                ..._buildFixedCenterProgress('Línea 2', 'linea2', Colors.teal, 90),
                ..._buildFixedCenterProgress('Línea 10', 'linea10', Colors.orangeAccent, 150),
                ..._buildFixedCenterProgress('Línea 11', 'linea11', Colors.redAccent, 210),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.middle,
          textStyle: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
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
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            final double realValue = double.tryParse((data[key] ?? 0).toString()) ?? 0;
            return Text(
              realValue.toInt().toString(),
              style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
    ];
  }

  ColumnSeries<dynamic, String> _buildColumnSeries(String name, String key, Color color) {
    return ColumnSeries<dynamic, String>(
      name: name,
      enableTooltip: true,
      dataSource: _fullRangeData,
      xValueMapper: (data, _) => _formatTime(data['_time_lima']),
      yValueMapper: (data, _) => data[key] ?? 0,
      color: color,
      width: 0.8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        showZeroValue: false,
        labelAlignment: ChartDataLabelAlignment.outer,
        textStyle: TextStyle(fontSize: 12, color: ColorDefaults.darkPrimary, fontWeight: FontWeight.bold),
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