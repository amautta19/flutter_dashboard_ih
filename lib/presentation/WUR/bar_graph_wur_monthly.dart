import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart'; // Importante
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Widget para mostrar el consumo diario
class BarGraphWurMonthly extends StatefulWidget {
  final List<dynamic> allData;  // Lista de toda la data
  final bool umbralInverso;     // Se revierte la condición del umbral del gráfico
  final String unidadM;         // Unidad de los valores (m3, %,...)
  final String titleM;
  final double widthGraph;   
  final int maxLabel;       // Título del gráfico
  const BarGraphWurMonthly({
    super.key, 
    required this.allData, 
    this.umbralInverso = false,       // Valor predeterminado desactivado 
    this.unidadM = '', 
    this.titleM = 'Consumo Agua (m³)',
    this.widthGraph = 0.50,
    this.maxLabel = 14,
  });

  @override
  State<BarGraphWurMonthly> createState() => _BarGraphWurMonthlyState();
}

class _BarGraphWurMonthlyState extends State<BarGraphWurMonthly> {
  late List<dynamic> _sortedData;

  @override
  void initState() {
    super.initState();
    _prepararDatos();
  }

  @override
  void didUpdateWidget(covariant BarGraphWurMonthly oldWidget) {
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
        DateTime fechaA = DateTime.parse(a['mes_label']);
        DateTime fechaB = DateTime.parse(b['mes_label']);
        return fechaA.compareTo(fechaB);
      } catch (e) {
        return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos valor de los providers
    final String selectedFilter = context.watch<FilterElementProvider>().getElement; // Filtro escogido
    final umbralesProvider = context.watch<UmbralesProvider>(); // Lista de umbrales de supabase

    // Buscamos en la tabla cargada en el provider si existe el elemento
    final umbralFila = umbralesProvider.tablaUmbrales.firstWhere(
      (u) => selectedFilter.contains(u['argumento']),
      orElse: () => {},
    );

    // Variables para la lógica de los umbrales
    double valorReferencia;
    String umbralLimite;
    Color colorReferencia;

    // Si existe un umbral en la tabla de supabase usamos ese
    valorReferencia = (umbralFila['umbral'] as num).toDouble();
    umbralLimite = 'Umbral Técnico: ${valorReferencia.toStringAsFixed(1)} ${widget.unidadM}';
    colorReferencia = Colors.orange; 
    // Si no existe umbral en la tabla de supabse se utiliza el promedio calculado

    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.35,
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
                '${widget.titleM} : $selectedFilter', // Título dinámico del gráfico
                color: ColorDefaults.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              // Mostrar el valor del umbral
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
          // Gráfico de barras
          Expanded(
            child: SfCartesianChart(
              key: ValueKey('chart_${selectedFilter}_$valorReferencia'),
              // Zoom en el eje X
              zoomPanBehavior: ZoomPanBehavior( 
                  enablePanning: true, 
                  zoomMode: ZoomMode.x
              ),
              // Configuración del Eje X
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: widget.maxLabel, // Máximo de barras en la vista 14
                autoScrollingMode: AutoScrollingMode.end,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  color: ColorDefaults.darkPrimary, fontSize: 11),
              ),
              // Configuración del Eje Y
              primaryYAxis: NumericAxis(
                minimum: 0, // Empieza en 0 el valor del eje
                rangePadding: ChartRangePadding.additional,
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 11),
                // Configuración de la vista del umbral
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
              // Configuración de los valores mostrados en la gráfica
              series: <CartesianSeries<dynamic, String>>[
                // Configuración de las barras de la gráfica
                ColumnSeries<dynamic, String>(
                  key: ValueKey('bars_$selectedFilter'),
                  name: 'WUR',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['mes_label']?.toString() ?? '',
                  yValueMapper: (data, _) => data['wur_mensual'] ?? 0, // Mostramos los valores del filtro
                  pointColorMapper: (data, _) {
                    final valor = data[selectedFilter] ?? 0;
                    // Se cambia la condición del umbral dependiendo del valor bool insertado en el widget
                    if(widget.umbralInverso == false){
                      return valor > valorReferencia ? Colors.red : Colors.green;
                    }else{
                      return valor < valorReferencia ? Colors.red : Colors.green;
                    }
                  },
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  // Configuración de los dataLabels
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      borderRadius: 5,
                      color: Colors.amberAccent.withOpacity(0.8),
                      textStyle: TextStyle(
                          fontSize: 10,
                          color: ColorDefaults.darkPrimary,
                          fontWeight: FontWeight.bold)),
                ),
                // Configuración de la Línea de tendencia evolución
                LineSeries<dynamic, String>(
                  key: ValueKey('line_$selectedFilter'),
                  name: 'Evolución',
                  dataSource: _sortedData,
                  xValueMapper: (data, _) => data['mes_label']?.toString() ?? '',
                  yValueMapper: (data, _) => data['wur_mensual'] ?? 0,
                  color: ColorDefaults.primaryBlue,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 4,
                    width: 4,
                    shape: DataMarkerType.circle,
                    color: Colors.blueAccent,
                  ),
                  animationDuration: 500,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}