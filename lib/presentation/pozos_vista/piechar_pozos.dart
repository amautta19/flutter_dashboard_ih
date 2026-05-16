import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';

class PozosPieChart extends StatefulWidget {
  final List<dynamic> allData;

  const PozosPieChart({super.key, required this.allData});

  @override
  State<PozosPieChart> createState() => _PozosPieChartState();
}

class _PozosPieChartState extends State<PozosPieChart> {
  List<Map<String, dynamic>> _chartData = [];
  double _ultimoTotal = 0;

  @override
  void initState() {
    super.initState();
    _procesarDatos();
  }

  @override
  void didUpdateWidget(PozosPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _procesarDatos();
    }
  }

  void _procesarDatos() {
    double t1 = 0;
    double t3 = 0;

    for (var reg in widget.allData) {
      t1 += (reg['Pozo1'] ?? 0).toDouble();
      t3 += (reg['Pozo3'] ?? 0).toDouble();
    }

    double nuevoTotal = t1 + t3;

    if (nuevoTotal != _ultimoTotal) {
      setState(() {
        _ultimoTotal = nuevoTotal;
        _chartData = [
          {'nombre': 'Pozo 1', 'valor': t1, 'color': ColorDefaults.darkCyan},
          {'nombre': 'Pozo 3', 'valor': t3, 'color': ColorDefaults.darkUmbral},
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;

    return Container(
      height: windowsSize.height * 0.35,
      width: windowsSize.width * 0.25,
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
      child: SfCircularChart(
        backgroundColor: Colors.transparent,
        title: ChartTitle(
          text: 'Distribución Total Pozos (m³)',
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorDefaults.secundaryBlue,
            fontSize: 14,
          ),
        ),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          textStyle: const TextStyle(
            color: ColorDefaults.darkTextMuted,
            fontSize: 12,
          ),
          iconHeight: 12,
          iconWidth: 12,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: ColorDefaults.darkBgHeader,
          textStyle: const TextStyle(
            color: ColorDefaults.darkTextPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          duration: 150,
          animationDuration: 0,
        ),
        series: <CircularSeries<Map<String, dynamic>, String>>[
          PieSeries<Map<String, dynamic>, String>(
            dataSource: _chartData,
            xValueMapper: (data, _) => data['nombre'],
            yValueMapper: (data, _) => data['valor'],
            pointColorMapper: (data, _) => data['color'],
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorDefaults.darkBgCard,
                fontSize: 12,
              ),
            ),
            animationDuration: 500,
          ),
        ],
      ),
    );
  }
}