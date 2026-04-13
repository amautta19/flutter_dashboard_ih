import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:intl/intl.dart';
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
      height: windowSize.height * 0.55,
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
                'Tiempo Efectivo por Línea',
                color: ColorDefaults.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  GlobalText('Grupos Compactos', color: ColorDefaults.darkPrimary, fontSize: 12),
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
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: TextStyle(fontSize: 10)
              ),
              zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true, 
                  zoomMode: ZoomMode.x
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: CategoryAxis(
                interval: 1,
                autoScrollingDelta: 12, 
                labelPlacement: LabelPlacement.betweenTicks,
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: Colors.black,
                  dashArray: <double>[5,5]
                ),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                rangePadding: ChartRangePadding.additional,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11),
              ),
              series: <ColumnSeries<dynamic, String>>[
                _buildColumnSeries('Línea 1', 'linea1', ColorDefaults.primaryBlue),
                _buildColumnSeries('Línea 2', 'linea2', Colors.teal),
                _buildColumnSeries('Línea 10', 'linea10', Colors.orangeAccent),
                _buildColumnSeries('Línea 11', 'linea11', Colors.redAccent),
              ],
            ),
          )
        ],
      ),
    );
  }

  ColumnSeries<dynamic, String> _buildColumnSeries(String name, String key, Color color) {
    return ColumnSeries<dynamic, String>(
      name: name,
      dataSource: _sortedData,
      xValueMapper: (data, _){
        final String fullTime = data['_time_lima']?.toString() ?? '';
        try{
          DateTime dt = DateTime.parse(fullTime);
          return DateFormat('HH:mm').format(dt);
        } catch (e){
          return fullTime;
        }
      },
      yValueMapper: (data, _) => data[key] ?? 0,
      color: color,
      spacing: 0, 
      width: 0.8, 
      // ----------------------------------------------
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        showZeroValue: false,
        // Rotamos los labels si quedan muy apretados
        labelAlignment: ChartDataLabelAlignment.outer,
        textStyle: TextStyle(
          fontSize: 12,
          color: ColorDefaults.darkPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}