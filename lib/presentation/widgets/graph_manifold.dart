import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart'; // Importante para escuchar el cambio
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphManifoldWidget extends StatefulWidget {
  final List<dynamic> allData;
  const GraphManifoldWidget({super.key, required this.allData});

  @override
  State<GraphManifoldWidget> createState() => _GraphManifoldWidgetState();
}

class _GraphManifoldWidgetState extends State<GraphManifoldWidget> {
  
  // Función para calcular el promedio dinámico basado en la columna seleccionada
  double _calcularPromedio(String column) {
    if (widget.allData.isEmpty) return 0;
    double suma = 0;
    for (var item in widget.allData) {
      // Usamos la columna dinámica pasada por parámetro
      suma += (item[column] ?? 0).toDouble();
    }
    return suma / widget.allData.length;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos la columna seleccionada desde el Provider
    final String selectedCol = context.watch<FilterElement>().selectedColumn;
    
    // 2. Calculamos el promedio para ESA columna específica
    final double promedio = _calcularPromedio(selectedCol);

    return Container(
      height: 450,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorDefaults.whitePrimary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorDefaults.whitePrimary),
      ),
      child: SfCartesianChart(
        title: ChartTitle(
          // Título dinámico según la variable
          text: 'Tendencia de consumo: $selectedCol',
          textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)
        ),
        tooltipBehavior: TooltipBehavior(enable: true, header: selectedCol),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
        primaryXAxis: CategoryAxis(
          labelRotation: 0,
          autoScrollingDelta: 14,
          autoScrollingMode: AutoScrollingMode.end,
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: 'Consumo (m³)', 
            textStyle: TextStyle(color: ColorDefaults.darkPrimary, fontWeight: FontWeight.bold)
          ),
          labelStyle: TextStyle(color: ColorDefaults.darkPrimary),
          plotBands: <PlotBand>[
            PlotBand(
              isVisible: true,
              start: promedio,
              end: promedio,
              borderWidth: 3,
              borderColor: Colors.orangeAccent,
              dashArray: <double>[6, 6],
              verticalTextAlignment: TextAnchor.end,
              // text: 'PROM. $selectedCol: ${promedio.toStringAsFixed(2)}',
              text: promedio.toStringAsFixed(2),
              textStyle: TextStyle(
                color: Colors.orangeAccent, 
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              horizontalTextAlignment: TextAnchor.end,
            )
          ],
        ),
        series: <CartesianSeries<dynamic, String>>[
          ColumnSeries<dynamic, String>(
            name: selectedCol,
            dataSource: widget.allData,
            xValueMapper: (data, _) => data['fecha_operativa']?.toString() ?? '',
            yValueMapper: (data, _) => data[selectedCol] ?? 0,
            pointColorMapper: (data, _) {
              final valor = data[selectedCol] ?? 0;
              return valor > promedio ? Colors.red : ColorDefaults.primaryBlue;
            },
            
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            dataLabelSettings: DataLabelSettings(
              borderRadius:  5,
              color: Colors.amberAccent,
              isVisible: true,
              textStyle: TextStyle(fontSize: 14, color: ColorDefaults.darkPrimary, fontWeight: FontWeight.bold)
            ),
            enableTooltip: true,
            // Animación suave al cambiar entre variables
            animationDuration: 1000, 
          )
        ],
      ),
    );
  }
}