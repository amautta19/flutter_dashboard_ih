import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';

class DistributionBarChart extends StatelessWidget {
  final List<dynamic> allData;
  
  const DistributionBarChart({super.key, required this.allData});

  List<_ChartData> _procesarDistribucion() {
    if (allData.isEmpty) return [];

    // 1. Definimos las columnas que queremos sumar
    final List<String> columnas = [
      'CIP', 'DesaireadorA', 'DesaireadorB', 'DesaireadorC', 
      'Fuerza', 'Lavadoras', 'LineasPET', 'Multimix', 
      'Potable', 'Quasy', 'Servicios', 'Contisiolv'
    ];

    Map<String, double> totales = {};

    // 2. Sumamos los valores de cada columna en toda la data filtrada
    for (var col in columnas) {
      double suma = 0;
      for (var item in allData) {
        suma += (item[col] ?? 0).toDouble();
      }
      totales[col] = suma;
    }

    // 3. Convertimos a lista y ordenamos de mayor a menor
    final listaData = totales.entries.map((e) => _ChartData(e.key, e.value)).toList();
    listaData.sort((a, b) => b.value.compareTo(a.value)); // Orden descendente

    return listaData;
  }

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;
    final chartData = _procesarDistribucion();

    return Container(
      height: windowsSize.height * 0.4,
      width: windowsSize.width * 0.25,
      // padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColorDefaults.whitePrimary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SfCartesianChart(
        title: ChartTitle(
          text: 'Distribución Total',
          alignment: ChartAlignment.near,
          textStyle: TextStyle(fontWeight: FontWeight.bold, color: ColorDefaults.darkPrimary)
        ),
        // Eje X ahora es el vertical en un BarChart
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        // Eje Y ahora es el horizontal
        primaryYAxis: NumericAxis(
          isVisible: false, // Ocultamos el eje para que se vea como en tu imagen
          majorGridLines: const MajorGridLines(width: 0),
        ),
        series: <CartesianSeries<_ChartData, String>>[
          BarSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.label,
            yValueMapper: (_ChartData data, _) => data.value,
            color: const Color(0xFF0084ED), // El azul de tu imagen
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
            // Etiquetas de datos al final de la barra
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.outer,
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
            ),
          )
        ],
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double value;
  _ChartData(this.label, this.value);
}