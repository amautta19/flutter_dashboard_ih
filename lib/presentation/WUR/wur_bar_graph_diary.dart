import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart'; 
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WurBarGraphDiary extends StatefulWidget {
  final List<dynamic> allData;
  final bool umbralInverso;
  final String unidadM;
  final String titleM;
  final double widthGraph;
  final int maxLabel;
  const WurBarGraphDiary({
    super.key, 
    required this.allData, 
    this.umbralInverso = false,
    this.unidadM = 'm³', 
    this.titleM = 'Consumo Agua (m³)',
    this.widthGraph = 0.60,
    this.maxLabel = 14,
  });

  @override
  State<WurBarGraphDiary> createState() => _WurBarGraphDiaryState();
}

class _WurBarGraphDiaryState extends State<WurBarGraphDiary> {
  late List<dynamic> _sortedData;

  @override
  void initState() {
    super.initState();
    _prepararDatos();
  }

  @override
  void didUpdateWidget(covariant WurBarGraphDiary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _prepararDatos();
    }
  }

  // Prearar los datos obtenidos de la lista
  void _prepararDatos() {
    // Ordename los datos de forma ascendente
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
    int cont = 0;
    for (var item in _sortedData) {
      final valor = (item[column] ?? 0).toDouble();
      if (valor > 0) {
        suma += valor;
        cont++;
      }
    }
    return cont > 0 ? suma / cont : 0;
  }

  @override
  Widget build(BuildContext context) {
    final String selectedFilter = context.watch<FilterElementProvider>().getElement; 
    final umbralesProvider = context.watch<UmbralesProvider>(); 

    final umbralFila = umbralesProvider.tablaUmbrales.firstWhere(
      (u) => selectedFilter.contains(u['argumento']),
      orElse: () => {},
    );

    double valorReferencia;
    String umbralLimite;
    Color colorReferencia;

    if (umbralFila.isNotEmpty && umbralFila['umbral'] != null) {
      valorReferencia = (umbralFila['umbral'] as num).toDouble();
      umbralLimite = 'Umbral Técnico: ${valorReferencia.toStringAsFixed(1)} ${widget.unidadM}';
      colorReferencia = Colors.orangeAccent; 
    } else {
      valorReferencia = _calcularPromedio(selectedFilter);
      umbralLimite = 'Promedio: ${valorReferencia.toStringAsFixed(1)} ${widget.unidadM}';
      colorReferencia = Colors.orangeAccent;
    }

    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.42,
      width: windowSize.width * widget.widthGraph,
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
                widget.titleM, 
                color: ColorDefaults.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: colorReferencia, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  GlobalText(
                    umbralLimite,
                    color: colorReferencia,
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
              key: ValueKey('chart_${selectedFilter}_$valorReferencia'),
              zoomPanBehavior: ZoomPanBehavior( 
                  enablePanning: true, 
                  zoomMode: ZoomMode.x
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: 'WUR',
                activationMode: ActivationMode.singleTap,
                duration: 500, 
              ),
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: widget.maxLabel, 
                autoScrollingMode: AutoScrollingMode.end,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  color: ColorDefaults.darkPrimary, fontSize: 11),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0, 
                maximum: 3.2,
                rangePadding: ChartRangePadding.additional,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11),
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: valorReferencia,
                    end: valorReferencia,
                    borderWidth: 2,
                    borderColor: colorReferencia,
                    dashArray: <double>[6, 6]
                  )
                ],
              ),
              series: <CartesianSeries<dynamic, String>>[
                ColumnSeries<dynamic, String>(
                  key: ValueKey('bars_$selectedFilter'),
                  name: 'Consumo',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['fecha_operativa']?.toString() ?? '',
                  yValueMapper: (data, _) => data[selectedFilter] ?? 0, 
                  pointColorMapper: (data, _) {
                    final valor = data[selectedFilter] ?? 0;
                    if(widget.umbralInverso == false){
                      return valor > valorReferencia ? Colors.red : Colors.green;
                    }else{
                      return valor < valorReferencia ? Colors.red : ColorDefaults.primaryBlue;
                    }
                  },
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    borderRadius: 5,
                    color: Colors.amberAccent.withOpacity(0.8),
                    textStyle: TextStyle(
                      fontSize: 10,
                      color: ColorDefaults.darkPrimary,
                      fontWeight: FontWeight.bold)
                  ),
                ),
                LineSeries<dynamic, String>(
                  key: ValueKey('line_$selectedFilter'),
                  name: 'Evolución',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['fecha_operativa']?.toString() ?? '',
                  yValueMapper: (data, _) => data[selectedFilter] ?? 0,
                  color: Colors.green,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 4,
                    width: 4,
                    shape: DataMarkerType.circle,
                    color: Colors.green,
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      color: ColorDefaults.darkPrimary
                    ),
                    labelAlignment: ChartDataLabelAlignment.outer
                  ),
                  animationDuration: 800,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}