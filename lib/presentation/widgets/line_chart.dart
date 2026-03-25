import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';

class LineTrendChart extends StatelessWidget {
  final List<dynamic> allData;

  const LineTrendChart({super.key, required this.allData});

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;
    
    // 1. Escuchamos qué columna queremos graficar (CIP, Lavadoras, etc.)
    final String selectedCol = context.watch<FilterElement>().selectedColumn;

    return Container(
      height: windowsSize.height * 0.42,
      width: windowsSize.width * 0.33, // Un poco más ancho que el de barras
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColorDefaults.whitePrimary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SfCartesianChart(
        title: ChartTitle(
          text: 'Evolución Temporal: $selectedCol',
          alignment: ChartAlignment.near,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold, 
            color: ColorDefaults.darkPrimary,
            fontSize: 14
          )
        ),
        // Tooltip para ver el valor exacto al pasar el mouse/dedo
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: 'Lectura',
          canShowMarker: true,
        ),
        // Permite hacer zoom en el tiempo si hay muchos datos
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          zoomMode: ZoomMode.x,
        ),
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 10),
          labelRotation: 45, // Rotamos las fechas para que no se amontonen
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: 'm³',
            textStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 10)
          ),
          majorGridLines: const MajorGridLines(
            width: 0.5,
            dashArray: <double>[5, 5],
          ),
        ),
        series: <CartesianSeries<dynamic, String>>[
          SplineSeries<dynamic, String>( // Spline crea una línea curva más suave
            name: selectedCol,
            dataSource: allData,
            xValueMapper: (data, _) => data['_time_lima']?.toString() ?? '',
            yValueMapper: (data, _) => data[selectedCol] ?? 0,
            color: ColorDefaults.primaryBlue, // Tu color preferido
            width: 3,
            // Añadimos puntos (markers) en cada lectura
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 6,
              width: 6,
              shape: DataMarkerType.circle,
              color: Colors.white,
              borderWidth: 2,
              borderColor: ColorDefaults.primaryBlue,
            ),
            // Animación al cargar o cambiar de variable
            animationDuration: 1200,
          )
        ],
      ),
    );
  }
}