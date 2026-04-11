import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraficaEficienciaDiaria extends StatelessWidget {
  final List<dynamic> dataCruda;

  const GraficaEficienciaDiaria({super.key, required this.dataCruda});

  @override
  Widget build(BuildContext context) {
    // Transformamos la data dinámica a una lista de mapas para facilitar el acceso
    // Asumiendo que tus columnas se llaman: 'hora' (o fecha), 'valor1', 'valor2', 'valor3', 'valor4'
    return SfCartesianChart(
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: CategoryAxis( // Usamos CategoryAxis para agrupar por etiquetas de tiempo/hora
        labelStyle: const TextStyle(color: Colors.white),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries<dynamic, String>>[
        ColumnSeries<dynamic, String>(
          name: 'Línea 1',
          dataSource: dataCruda,
          xValueMapper: (data, _) => data['_time_lima'].toString(), // Cambia por tu columna de tiempo
          yValueMapper: (data, _) => data['linea1'],
          color: Colors.blueAccent,
        ),
        ColumnSeries<dynamic, String>(
          name: 'Línea 2',
          dataSource: dataCruda,
          xValueMapper: (data, _) => data['_time_lima'].toString(),
          yValueMapper: (data, _) => data['linea2'],
          color: Colors.greenAccent,
        ),
        ColumnSeries<dynamic, String>(
          name: 'Línea 3',
          dataSource: dataCruda,
          xValueMapper: (data, _) => data['_time_lima'].toString(),
          yValueMapper: (data, _) => data['linea10'],
          color: Colors.orangeAccent,
        ),
        ColumnSeries<dynamic, String>(
          name: 'Línea 4',
          dataSource: dataCruda,
          xValueMapper: (data, _) => data['_time_lima'].toString(),
          yValueMapper: (data, _) => data['linea11'],
          color: Colors.redAccent,
        ),
      ],
    );
  }
}