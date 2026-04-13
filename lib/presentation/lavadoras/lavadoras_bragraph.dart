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
          
          // --- GRÁFICA SUPERIOR ---
          Expanded(
            flex: 4,
            child: SfCartesianChart(
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
                labelStyle: TextStyle(fontSize: 0),
                minimum: 0,
                maximum: 80,
                title: AxisTitle(
                  text: 'Consumo Total Lavadoras',
                  textStyle: TextStyle(fontSize: 14, color: ColorDefaults.darkPrimary)
                ),
                ),
              series: <CartesianSeries<dynamic, String>>[
                _buildColumnSeries('Lavadoras', 'Lavadoras', ColorDefaults.primaryBlue)
              ],
            ),
          ),

          // --- GRÁFICA INFERIOR: BLOQUES DE 60 MINUTOS INDEPENDIENTES ---
          Expanded(
            flex: 6,
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
                majorGridLines: const MajorGridLines(width: 1, color: Colors.black, dashArray: [5,5]),
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Minutos Efectivos por Línea',
                  textStyle: TextStyle(fontSize: 14, color: ColorDefaults.darkPrimary)
                ),
                minimum: 0,
                maximum: 240, 
                interval: 60,
                labelStyle: const TextStyle(fontSize: 0),
              ),
              series: <CartesianSeries<dynamic, String>>[
                // LÍNEA 1: Bloque de 60. Su centro está en Y = 30
                ..._buildFixedCenterProgress('Línea 1', 'linea1', ColorDefaults.primaryBlue, 30),
                // LÍNEA 2: Bloque de 60. Su centro está en Y = 90 (60 + 30)
                ..._buildFixedCenterProgress('Línea 2', 'linea2', Colors.teal, 90),
                // LÍNEA 10: Bloque de 60. Su centro está en Y = 150 (120 + 30)
                ..._buildFixedCenterProgress('Línea 10', 'linea10', Colors.orangeAccent, 150),
                // LÍNEA 11: Bloque de 60. Su centro está en Y = 210 (180 + 30)
                ..._buildFixedCenterProgress('Línea 11', 'linea11', Colors.redAccent, 210),
              ],
            ),
          )
        ],
      ),
    );
  }

  // NUEVA FUNCIÓN QUE UTILIZA UN SCATTER INVISIBLE PARA EL CENTRADO PERFECTO
  List<CartesianSeries<dynamic, String>> _buildFixedCenterProgress(
      String name, String key, Color color, double fixedCenterY) {
    return [
      // 1. Parte real pintada (Sin labels)
      StackedColumnSeries<dynamic, String>(
        name: name,
        dataSource: _sortedData,
        xValueMapper: (data, _) => _formatTime(data['_time_lima']),
        yValueMapper: (data, _) => data[key] ?? 0,
        color: color,
        width: 0.8,
        dataLabelSettings: const DataLabelSettings(isVisible: false), // Quitamos labels de aquí
      ),
      // 2. Parte sombreada (El fondo restante, sin labels)
      StackedColumnSeries<dynamic, String>(
        name: '$name (Resto)',
        dataSource: _sortedData,
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
        dataLabelSettings: const DataLabelSettings(isVisible: false), // Quitamos labels de aquí
      ),
      // 3. LA CLAVE: Serie invisible al centro perfecto del bloque de 60
      ScatterSeries<dynamic, String>(
        dataSource: _sortedData,
        xValueMapper: (data, _) => _formatTime(data['_time_lima']),
        // Lo posicionamos exactamente en el centro fijo del bloque
        yValueMapper: (data, _) => fixedCenterY, 
        color: Colors.transparent, // Invisible
        markerSettings: const MarkerSettings(isVisible: false), // Sin punto
        isVisibleInLegend: false,
        // Usamos sus DataLabels para el valor real
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          showZeroValue: true, // Queremos ver el "0"
          // Usamos un template para mostrar el valor REAL de la línea, no el fixedCenterY
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            final double realValue = double.tryParse((data[key] ?? 0).toString()) ?? 0;
            // Mostramos el valor real formateado como entero
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
    dataSource: _sortedData,
    xValueMapper: (data, _) => _formatTime(data['_time_lima']),
    yValueMapper: (data, _) => data[key] ?? 0,
    color: color,
    width: 0.8,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
    // CONFIGURACIÓN DE LOS LABELS
    dataLabelSettings: DataLabelSettings(
      isVisible: true, // Asegúrate de que esto esté en true
      showZeroValue: false, // Opcional: no muestra el "0" para no saturar
      labelAlignment: ChartDataLabelAlignment.outer, // Pone el número ARRIBA de la barra
      textStyle: TextStyle(
        fontSize: 12, 
        color: ColorDefaults.darkPrimary, // O el color que prefieras para que resalte
        fontWeight: FontWeight.bold
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