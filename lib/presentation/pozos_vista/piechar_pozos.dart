import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';

class _PieData {
  _PieData(this.xData, this.yData, this.color);
  final String xData;
  final double yData;
  final Color color;
}

class PozosPieChart extends StatelessWidget {
  final List<dynamic> allData;

  const PozosPieChart({super.key, required this.allData});

  // --- LÓGICA DE SUMA TOTAL ---
  List<_PieData> _prepararDatos() {
    if (allData.isEmpty) return [];

    double totalPozo1 = 0;
    double totalPozo3 = 0;

    // Recorremos toda la data para sumar
    for (var registro in allData) {
      totalPozo1 += (registro['Pozo1'] ?? 0).toDouble();
      totalPozo3 += (registro['Pozo3'] ?? 0).toDouble();
    }

    if (totalPozo1 == 0 && totalPozo3 == 0) return [];

    return [
      _PieData('Pozo 1', totalPozo1, ColorDefaults.primaryBlue),
      _PieData('Pozo 3', totalPozo3, Colors.orangeAccent),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;
    final List<_PieData> pieData = _prepararDatos();

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
          alignment: ChartAlignment.near,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorDefaults.primaryBlue,
            fontSize: 14,
          ),
        ),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
        ),
        // TOOLTIP: Para que desaparezca rápido como querías en los otros gráficos
        tooltipBehavior: TooltipBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          duration: 150, // Rápido al salir
          animationDuration: 0,
          format: 'point.x : point.y m³',
        ),
        series: <CircularSeries<_PieData, String>>[
          PieSeries<_PieData, String>(
            dataSource: pieData,
            xValueMapper: (_PieData data, _) => data.xData,
            yValueMapper: (_PieData data, _) => data.yData,
            pointColorMapper: (_PieData data, _) => data.color,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            animationDuration: 800,
          )
        ],
      ),
    );
  }
}