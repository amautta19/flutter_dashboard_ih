import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart'; // Importante
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarGraphDiary extends StatefulWidget {
  final List<dynamic> allData;
  final bool umbralInverso;
  final String unidadM;
  final String titleM;
  const BarGraphDiary({super.key, required this.allData, this.umbralInverso = false, this.unidadM = 'm³', this.titleM = 'Consumo Agua (m³)'});

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
    int cont = 0;
    for (var item in _sortedData) {
      final valor = (item[column] ?? 0).toDouble();
      if (valor > 0) { // Opcional: solo promediar días con consumo
        suma += valor;
        cont++;
      }
    }
    return cont > 0 ? suma / cont : 0;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Escuchamos los Providers
    final String selectedFilter = context.watch<FilterElementProvider>().getElement;
    final umbralesProv = context.watch<UmbralesProvider>();

    // 2. LÓGICA DINÁMICA DE UMBRALES
    // Buscamos en la tabla cargada en el provider si existe el elemento
    final umbralFila = umbralesProv.tablaUmbrales.firstWhere(
      (u) => selectedFilter.contains(u['argumento']),
      orElse: () => {},
    );

    double valorReferencia;
    String etiquetaReferencia;
    Color colorReferencia;

    if (umbralFila.isNotEmpty && umbralFila['umbral'] != null) {
      // Si existe en la tabla de Supabase, usamos ese límite
      valorReferencia = (umbralFila['umbral'] as num).toDouble();
      etiquetaReferencia = 'Umbral Técnico: ${valorReferencia.toStringAsFixed(1)} ${widget.unidadM}';
      colorReferencia = Colors.orangeAccent; 
    } else {
      
      valorReferencia = _calcularPromedio(selectedFilter);
      etiquetaReferencia = 'Promedio: ${valorReferencia.toStringAsFixed(1)} ${widget.unidadM}';
      colorReferencia = Colors.orangeAccent;
    }

    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.42,
      width: windowSize.width * 0.60,
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
                '${widget.titleM} : $selectedFilter',
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
                    etiquetaReferencia,
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
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: 14,
                autoScrollingMode: AutoScrollingMode.end,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                    color: ColorDefaults.darkPrimary, fontSize: 11),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                rangePadding: ChartRangePadding.additional,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11),
                plotBands: <PlotBand>[
                  PlotBand(
                      isVisible: true,
                      start: valorReferencia,
                      end: valorReferencia,
                      borderWidth: 2,
                      borderColor: colorReferencia,
                      dashArray: <double>[6, 6])
                ],
              ),
              series: <CartesianSeries<dynamic, String>>[
                // BARRAS
                ColumnSeries<dynamic, String>(
                  key: ValueKey('bars_$selectedFilter'),
                  name: 'Consumo',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['fecha_operativa']?.toString() ?? '',
                  yValueMapper: (data, _) => data[selectedFilter] ?? 0,
                  pointColorMapper: (data, _) {
                    final valor = data[selectedFilter] ?? 0;
                    // Si supera el umbral o promedio, se pinta de rojo
                    if(widget.umbralInverso == false){
                      return valor > valorReferencia ? Colors.red : ColorDefaults.primaryBlue;

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
                          fontWeight: FontWeight.bold)),
                ),

                // LÍNEA DE EVOLUCIÓN
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
                  animationDuration: 1200,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}