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
  late List<dynamic> _sortedData;

  @override
  void initState() {
    super.initState();
    _prepararDatos();
  }

  @override
  void didUpdateWidget(covariant BarGraphDiaryMulti oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.75, // Aumentamos el alto para acomodar ambas
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
          
          // --- GRÁFICA SUPERIOR: CONSUMO TOTAL (BARRAS) ---
          Expanded(
            flex: 1,
            child: SfCartesianChart(
              title: ChartTitle(
                text: 'Consumo Total Agua (m³)', 
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                isVisible: true,
                autoScrollingDelta: 24,
                  majorGridLines: const MajorGridLines(width: 1, dashArray: [5, 5]),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 9),
              ),
              series: <ColumnSeries<dynamic, String>>[
                _buildColumnSeries('Lavadoras', 'Lavadoras', ColorDefaults.primaryBlue)
                // ColumnSeries<dynamic, String>(
                //   name: 'Consumo Total',
                //   dataSource: _sortedData,
                //   xValueMapper: (data, _) => _formatTime(data['_time_lima']),
                //   yValueMapper: (data, _) => data['Lavadoras'] ?? 0, // El dato de tu vista
                //   color: Colors.purple.withOpacity(0.6),
                //   borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                //   dataLabelSettings: const DataLabelSettings(
                //     isVisible: true,
                //     textStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                //   ),
                // )
              ],
            ),
          ),
          const SizedBox(height: 50),
          // --- GRÁFICA INFERIOR: DETALLE POR LÍNEA ---
          Expanded(
            flex: 1,
            child: SfCartesianChart(
              legend: const Legend(
                isVisible: true, 
                position: LegendPosition.bottom,
                textStyle: TextStyle(fontSize: 10)
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                interval: 1,
                autoScrollingDelta: 24, 
                labelPlacement: LabelPlacement.betweenTicks,
                majorGridLines: const MajorGridLines(width: 1, color: Colors.black26, dashArray: [5,5]),
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                rangePadding: ChartRangePadding.additional,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11),
              ),
              series: <ColumnSeries<dynamic, String>>[
                _buildColumnSeries('Línea 1', 'linea1', ColorDefaults.primaryBlue),
                _buildColumnSeries('Línea 2', 'linea2', Colors.teal),
                _buildColumnSeries('Línea 10', 'linea10', Colors.orangeAccent),
                _buildColumnSeries('Línea 11', 'linea11', Colors.redAccent),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper para formatear la hora
  String _formatTime(dynamic timeData) {
    final String fullTime = timeData?.toString() ?? '';
    try {
      DateTime dt = DateTime.parse(fullTime);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return fullTime;
    }
  }

  ColumnSeries<dynamic, String> _buildColumnSeries(String name, String key, Color color) {
    return ColumnSeries<dynamic, String>(
      name: name,
      dataSource: _sortedData,
      xValueMapper: (data, _) => _formatTime(data['_time_lima']),
      yValueMapper: (data, _) => data[key] ?? 0,
      color: color,
      spacing: 0, 
      width: 0.8, 
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        showZeroValue: false,
        labelAlignment: ChartDataLabelAlignment.outer,
        textStyle: TextStyle(fontSize: 9, color: ColorDefaults.darkPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}