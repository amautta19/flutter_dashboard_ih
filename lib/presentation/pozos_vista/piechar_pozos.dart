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

  // ESTA ES LA CLAVE: Solo actualiza si los valores de los pozos cambiaron
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

    // Solo disparamos el redibujo si la suma cambió
    if (nuevoTotal != _ultimoTotal) {
      setState(() {
        _ultimoTotal = nuevoTotal;
        _chartData = [
          {'nombre': 'Pozo 1', 'valor': t1, 'color': ColorDefaults.primaryBlue},
          {'nombre': 'Pozo 3', 'valor': t3, 'color': Colors.orangeAccent},
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
            dataSource: _chartData, // Usamos la data del estado
            xValueMapper: (data, _) => data['nombre'],
            yValueMapper: (data, _) => data['valor'],
            pointColorMapper: (data, _) => data['color'],
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            // Animación más corta para que sea fluido
            animationDuration: 500, 
          )
        ],
      ),
    );
  }
}