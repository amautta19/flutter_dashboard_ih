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
      height: windowSize.height * 0.80,
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
          
          // --- GRÁFICA SUPERIOR: CONSUMO TOTAL (COLUMNAS SIMPLES) ---
          Expanded(
            flex: 3,
            child: SfCartesianChart(
              title: ChartTitle(
                text: 'Consumo Total Lavadoras (m³)', 
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                isVisible: true,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 0, fontWeight: FontWeight.bold),
                autoScrollingDelta: 24,
                majorGridLines: const MajorGridLines(width: 1, color: Colors.black, dashArray: [5, 5]),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                labelStyle: TextStyle(fontSize: 0),
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

          // --- GRÁFICA INFERIOR: DETALLE POR LÍNEA (STACKED / APILADO) ---
          Expanded(
            flex: 7,
            child: SfCartesianChart(
              legend: const Legend(
                isVisible: true, 
                position: LegendPosition.bottom,
                textStyle: TextStyle(fontSize: 12)
              ),
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
              primaryXAxis: CategoryAxis(
                interval: 1,
                autoScrollingDelta: 24, 
                labelPlacement: LabelPlacement.betweenTicks,
                majorGridLines: const MajorGridLines(width: 1, color: Colors.black, dashArray: [5,5]),
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                rangePadding: ChartRangePadding.additional,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 0),
                title: AxisTitle(
                  text: 'Minutos Efectivos por Línea',
                  textStyle: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold)
                ),
              ),
              series: <StackedColumnSeries<dynamic, String>>[
                _buildStackedSeries('Línea 1', 'linea1', ColorDefaults.primaryBlue),
                _buildStackedSeries('Línea 2', 'linea2', Colors.teal),
                _buildStackedSeries('Línea 10', 'linea10', Colors.orangeAccent),
                _buildStackedSeries('Línea 11', 'linea11', Colors.redAccent),
              ],
            ),
          )
        ],
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

  // Helper para Columnas normales (Gráfica Superior)
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
        textStyle: TextStyle(fontSize: 12, color: ColorDefaults.darkPrimary),
      ),
    );
  }

  // NUEVO Helper para Columnas Apiladas (Gráfica Inferior)
  StackedColumnSeries<dynamic, String> _buildStackedSeries(String name, String key, Color color) {
    return StackedColumnSeries<dynamic, String>(
      name: name,
      dataSource: _sortedData,
      xValueMapper: (data, _) => _formatTime(data['_time_lima']),
      yValueMapper: (data, _) => data[key] ?? 0,
      color: color,
      width: 0.8,
      // En stacked no usamos borderRadius vertical arriba porque se vería raro entre bloques
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        showZeroValue: false,
        labelAlignment: ChartDataLabelAlignment.middle, // Etiquetas dentro de cada bloque
        textStyle: TextStyle(fontSize: 12, color: ColorDefaults.whitePrimary),
      ),
    );
  }
}