import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarGraphDiaryMulti extends StatefulWidget {
  final List<dynamic> allData;
  const BarGraphDiaryMulti({super.key, required this.allData});

  @override
  State<BarGraphDiaryMulti> createState() => _BarGraphDiaryMultiState();
}

class _BarGraphDiaryMultiState extends State<BarGraphDiaryMulti> {
  late List<dynamic> _sortedData;

  @override
  void initState() {
    super.initState();
    _prepararDatos();
  }

  @override
  void didUpdateWidget(covariant BarGraphDiaryMulti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _prepararDatos();
    }
  }

  void _prepararDatos() {
    _sortedData = List.from(widget.allData);
    _sortedData.sort((a, b) {
      try {
        DateTime fechaA = DateTime.parse(a['fecha_operativa']);
        DateTime fechaB = DateTime.parse(b['fecha_operativa']);
        return fechaA.compareTo(fechaB);
      } catch (e) {
        return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.42,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: ColorDefaults.whitePrimary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: ColorDefaults.whitePrimary)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlobalText(
                'Tiempo Efectivo por Categoría',
                color: ColorDefaults.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              // Indicador visual simple
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  GlobalText('Comparativo', color: ColorDefaults.darkPrimary, fontSize: 12),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SfCartesianChart(
              legend: const Legend(
                isVisible: true, 
                position: LegendPosition.bottom,
                textStyle: TextStyle(fontSize: 10)
              ),
              zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true, 
                  zoomMode: ZoomMode.x
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: 12, // Ajustado para ver mejor los grupos de 4
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                rangePadding: ChartRangePadding.additional,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11),
              ),
              series: <CartesianSeries<dynamic, String>>[
                // Barra 1 - Reemplaza 'valor1' con el nombre real de tu columna
                ColumnSeries<dynamic, String>(
                  name: 'Línea 1',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['_time_lima']?.toString() ?? '',
                  yValueMapper: (data, _) => data['linea1'] ?? 0,
                  color: ColorDefaults.primaryBlue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      borderRadius: 5,
                      color: Colors.amberAccent,
                      textStyle: TextStyle(
                          fontSize: 11,
                          color: ColorDefaults.darkPrimary,
                          fontWeight: FontWeight.bold)),
                ),
                // Barra 2
                ColumnSeries<dynamic, String>(
                  name: 'Línea 2',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['_time_lima']?.toString() ?? '',
                  yValueMapper: (data, _) => data['linea2'] ?? 0,
                  color: Colors.teal,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      borderRadius: 5,
                      color: Colors.amberAccent,
                      textStyle: TextStyle(
                          fontSize: 11,
                          color: ColorDefaults.darkPrimary,
                          fontWeight: FontWeight.bold)),
                ),
                // Barra 3
                ColumnSeries<dynamic, String>(
                  name: 'Línea 10',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['_time_lima']?.toString() ?? '',
                  yValueMapper: (data, _) => data['linea10'] ?? 0,
                  color: Colors.orangeAccent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      borderRadius: 5,
                      color: Colors.amberAccent,
                      textStyle: TextStyle(
                          fontSize: 11,
                          color: ColorDefaults.darkPrimary,
                          fontWeight: FontWeight.bold)),
                ),
                // Barra 4
                ColumnSeries<dynamic, String>(
                  name: 'Línea 11',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['_time_lima']?.toString() ?? '',
                  yValueMapper: (data, _) => data['linea11'] ?? 0,
                  color: Colors.redAccent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      borderRadius: 5,
                      color: Colors.amberAccent,
                      textStyle: TextStyle(
                          fontSize: 11,
                          color: ColorDefaults.darkPrimary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}