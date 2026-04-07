import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarGraphDiary extends StatefulWidget {
  final List<dynamic> allData;
  const BarGraphDiary({super.key, required this.allData});

  @override
  State<BarGraphDiary> createState() => _BarGraphDiaryState();
}

class _BarGraphDiaryState extends State<BarGraphDiary> {
  late List<dynamic> _sortedData;

  @override
  void initState() {
    super.initState();
    _prepararDatos();
  }

  @override
  void didUpdateWidget(covariant BarGraphDiary oldWidget) {
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

  double _calcularPromedio(String column) {
    if (_sortedData.isEmpty) return 0;
    double suma = 0;
    for (var item in _sortedData) {
      suma += (item[column] ?? 0).toDouble();
    }
    return suma / _sortedData.length;
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el cambio del filtro (ej. AF01, AF02, etc)
    final String selectedFilter = context.watch<FilterElementProvider>().getElement;
    final double promedio = _calcularPromedio(selectedFilter);
    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.42,
      width: windowSize.width * 0.60,
      padding: const EdgeInsets.all(5),
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
                'Consumo de Agua (m³): $selectedFilter',
                color: ColorDefaults.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: Colors.orangeAccent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  GlobalText(
                    'Promedio: ${promedio.toStringAsFixed(1)} m³',
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SfCartesianChart(
              // Usamos una Key en el chart para forzar el redibujado completo si falla la serie
              key: ValueKey('chart_$selectedFilter'),
              zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true, 
                  zoomMode: ZoomMode.x
              ),
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: 14,
                autoScrollingMode: AutoScrollingMode.end,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                    color: ColorDefaults.darkPrimary, fontSize: 12),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                // Agrega espacio arriba para que la línea y labels no se corten
                rangePadding: ChartRangePadding.additional,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary),
                plotBands: <PlotBand>[
                  PlotBand(
                      isVisible: true,
                      start: promedio,
                      end: promedio,
                      borderWidth: 2,
                      borderColor: Colors.orangeAccent,
                      dashArray: <double>[6, 6])
                ],
              ),
              series: <CartesianSeries<dynamic, String>>[
                // Serie 1: BARRAS
                ColumnSeries<dynamic, String>(
                  // La Key obliga a refrescar la serie al cambiar el filtro
                  key: ValueKey('bars_$selectedFilter'),
                  name: 'Consumo',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['fecha_operativa']?.toString() ?? '',
                  yValueMapper: (data, _) => data[selectedFilter] ?? 0,
                  pointColorMapper: (data, _) {
                    final valor = data[selectedFilter] ?? 0;
                    return valor > promedio ? Colors.red : ColorDefaults.primaryBlue;
                  },
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      borderRadius: 5,
                      color: Colors.amberAccent,
                      textStyle: TextStyle(
                          fontSize: 11,
                          color: ColorDefaults.darkPrimary,
                          fontWeight: FontWeight.bold)),
                ),

                // Serie 2: LÍNEA DE EVOLUCIÓN RECTA
                LineSeries<dynamic, String>(
                  // La Key obliga a la línea a buscar los nuevos datos del mapeo
                  key: ValueKey('line_$selectedFilter'),
                  name: 'Evolución',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['fecha_operativa']?.toString() ?? '',
                  yValueMapper: (data, _) => data[selectedFilter] ?? 0,
                  color: Colors.green,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    shape: DataMarkerType.circle,
                    color: Colors.green,
                  ),
                  animationDuration: 1000,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}