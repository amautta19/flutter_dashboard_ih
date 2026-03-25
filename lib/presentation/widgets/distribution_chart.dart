import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';

class DistributionBarChart extends StatelessWidget {
  final List<dynamic> allData;
  
  const DistributionBarChart({super.key, required this.allData});

  List<_ChartData> _procesarDistribucion() {
    if (allData.isEmpty) return [];

    // 1. Definimos las columnas que queremos sumar (Zonas del Manifold)
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

    // 3. Convertimos a lista y ordenamos de mayor a menor consumo
    final listaData = totales.entries.map((e) => _ChartData(e.key, e.value)).toList();
    listaData.sort((a, b) => b.value.compareTo(a.value)); 

    return listaData;
  }

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;
    final chartData = _procesarDistribucion();

    return Container(
      height: windowsSize.height * 0.35,
      width: windowsSize.width * 0.27,
      // padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: ColorDefaults.whitePrimary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SfCartesianChart(
        title: ChartTitle(
          text: 'Consumo Total Agua (m³)',
          alignment: ChartAlignment.near,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold, 
            color: ColorDefaults.primaryBlue, 
            fontSize: 14
          )
        ),
        
        // --- EJE X (Vertical en BarChart) ---
        primaryXAxis: CategoryAxis(
          isInversed: true, // Mantiene el mayor arriba
          majorGridLines: const MajorGridLines(width: 0),
          
          // FORZAR TODOS LOS LABELS:
          interval: 1, // Muestra cada una de las 12 zonas
          labelIntersectAction: AxisLabelIntersectAction.none, // Que no oculte nada
          
          labelStyle: TextStyle(
            color: ColorDefaults.darkPrimary, 
            fontSize: 12, // Tamaño reducido para asegurar que entren todos
            // fontWeight: FontWeight.w500
          ),
        ),

        // --- EJE Y (Horizontal) ---
        primaryYAxis: NumericAxis(
          isVisible: false, // Oculto para estilo limpio
          majorGridLines: const MajorGridLines(width: 0),
        ),

        series: <CartesianSeries<_ChartData, String>>[
          BarSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.label,
            yValueMapper: (_ChartData data, _) => data.value,
            color: ColorDefaults.primaryBlue,
            
            // Ajuste de grosor de barras
            width: 0.7, 
            spacing: 0.2,
            
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
            
            // Etiquetas de datos al final de cada barra
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.outer,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                color: Colors.black87
              )
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