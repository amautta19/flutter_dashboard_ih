import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphManifoldWidget extends StatefulWidget {
  final List<dynamic> allData;
  const GraphManifoldWidget({super.key, required this.allData});

  @override
  State<GraphManifoldWidget> createState() => _GraphManifoldWidgetState();
}

class _GraphManifoldWidgetState extends State<GraphManifoldWidget> {
  
  // Función para calcular el promedio real de los datos recibidos
  double _calcularPromedio() {
    if (widget.allData.isEmpty) return 0;
    double suma = 0;
    for (var item in widget.allData) {
      suma += (item['CIP'] ?? 0);
    }
    return suma / widget.allData.length;
  }

  @override
  Widget build(BuildContext context) {
    final double promedio = _calcularPromedio();

    return Container(
      height: 450,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Fondo sutil para modo oscuro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: SfCartesianChart(
        title: ChartTitle(
          text: 'Análisis de Consumo CIP',
          textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
        primaryXAxis: CategoryAxis(
          labelRotation: 45,
          autoScrollingDelta: 14,
          autoScrollingMode: AutoScrollingMode.end,
          majorGridLines: const MajorGridLines(width: 0), // Limpiamos líneas de fondo
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Consumo (m³)'),
          // --- LÍNEA DE PROMEDIO DINÁMICA ---
          plotBands: <PlotBand>[
            PlotBand(
              isVisible: true,
              start: promedio,
              end: promedio,
              borderWidth: 3,
              borderColor: Colors.orangeAccent,
              dashArray: <double>[6, 6],
              text: 'PROMEDIO: ${promedio.toStringAsFixed(2)}',
              textStyle: const TextStyle(
                color: Colors.orangeAccent, 
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black45
              ),
              horizontalTextAlignment: TextAnchor.end,
            )
          ],
        ),
        series: <CartesianSeries<dynamic, String>>[
          ColumnSeries<dynamic, String>(
            name: 'Consumo CIP',
            dataSource: widget.allData,
            xValueMapper: (data, _) => data['fecha_operativa'].toString(),
            yValueMapper: (data, _) => data['CIP'] ?? 0,
            
            // --- COLORES DINÁMICOS POR BARRA ---
            // Si el valor supera el promedio, se pinta de rojo
            pointColorMapper: (data, _) {
              final valor = data['CIP'] ?? 0;
              return valor > promedio ? Colors.redAccent : Colors.blueAccent;
            },
            
            // Diseño de las barras
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 10, color: Colors.white)
            ),
            enableTooltip: true,
          )
        ],
      ),
    );
  }
}