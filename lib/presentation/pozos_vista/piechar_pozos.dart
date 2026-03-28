import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';

class PozosPieChart extends StatelessWidget {
  final List<dynamic> allData;

  const PozosPieChart({super.key, required this.allData});

  // --- SUMA DIRECTA EN UN MAPA ---
  List<Map<String, dynamic>> _prepararDatos() {
    if (allData.isEmpty) return [];

    double total1 = 0;
    double total3 = 0;

    for (var reg in allData) {
      total1 += (reg['Pozo1'] ?? 0).toDouble();
      total3 += (reg['Pozo3'] ?? 0).toDouble();
    }

    if (total1 == 0 && total3 == 0) return [];

    // Retornamos mapas crudos con la info
    return [
      {'nombre': 'Pozo 1', 'valor': total1, 'color': ColorDefaults.primaryBlue},
      {'nombre': 'Pozo 3', 'valor': total3, 'color': Colors.orangeAccent},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;
    final data = _prepararDatos();

    return Container(
      height: windowsSize.height * 0.35,
      width: windowsSize.width * 0.25,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorDefaults.whitePrimary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SfCircularChart(
        title: ChartTitle(
          text: 'Distribución Total Pozos (m³)',
          textStyle: TextStyle(fontWeight: FontWeight.bold, color: ColorDefaults.primaryBlue, fontSize: 14),
        ),
        legend: const Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true, duration: 150, animationDuration: 0),
        series: <CircularSeries<Map<String, dynamic>, String>>[
          PieSeries<Map<String, dynamic>, String>(
            dataSource: data,
            // Aquí le decimos qué llaves del mapa usar
            xValueMapper: (Map<String, dynamic> row, _) => row['nombre'],
            yValueMapper: (Map<String, dynamic> row, _) => row['valor'],
            pointColorMapper: (Map<String, dynamic> row, _) => row['color'],
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}