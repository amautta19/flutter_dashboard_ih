import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';

class DistributionBarChart extends StatelessWidget {
  final List<String> columns;
  final List<dynamic> allData;

  const DistributionBarChart({super.key, required this.allData, required this.columns});

  List<_ChartData> _procesarDistribucion() {
    if (allData.isEmpty) return [];

    Map<String, double> totales = {};

    for (var col in columns) {
      double suma = 0;
      for (var item in allData) {
        suma += (item[col] ?? 0).toDouble();
      }
      totales[col] = suma;
    }

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorDefaults.darkBgCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorDefaults.darkBgBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SfCartesianChart(
        backgroundColor: Colors.transparent,
        plotAreaBackgroundColor: Colors.transparent,
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: ColorDefaults.darkBgHeader,
          textStyle: const TextStyle(
            color: ColorDefaults.darkTextPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          duration: 150,
        ),
        title: ChartTitle(
          text: 'Consumo Total Agua (m³)',
          alignment: ChartAlignment.near,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorDefaults.darkCyan,
            fontSize: 14,
          ),
        ),
        primaryXAxis: CategoryAxis(
          isInversed: true,
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
          interval: 1,
          labelIntersectAction: AxisLabelIntersectAction.none,
          labelStyle: const TextStyle(
            color: ColorDefaults.darkTextMuted,
            fontSize: 11,
          ),
        ),
        primaryYAxis: NumericAxis(
          isVisible: false,
          majorGridLines: const MajorGridLines(width: 0),
        ),
        series: <CartesianSeries<_ChartData, String>>[
          BarSeries<_ChartData, String>(
            dataSource: chartData,
            enableTooltip: true,
            xValueMapper: (_ChartData data, _) => data.label,
            yValueMapper: (_ChartData data, _) => data.value,
            color: ColorDefaults.darkCyan,
            width: 0.7,
            spacing: 0.2,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.outer,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: ColorDefaults.darkTextMuted,
              ),
            ),
          ),
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