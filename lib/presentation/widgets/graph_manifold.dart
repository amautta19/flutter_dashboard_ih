import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart'; 
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphManifoldWidget extends StatefulWidget {
  final List<dynamic> allData;
  const GraphManifoldWidget({super.key, required this.allData});

  @override
  State<GraphManifoldWidget> createState() => _GraphManifoldWidgetState();
}

class _GraphManifoldWidgetState extends State<GraphManifoldWidget> {
  
  double _calcularPromedio(String column) {
    if (widget.allData.isEmpty) return 0;
    double suma = 0;
    for (var item in widget.allData) {
      suma += (item[column] ?? 0).toDouble();
    }
    return suma / widget.allData.length;
  }

  @override
  Widget build(BuildContext context) {
    final String selectedCol = context.watch<FilterElement>().selectedColumn;
    final double promedio = _calcularPromedio(selectedCol);
    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.42,
      width: windowSize.width * 0.65,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColorDefaults.whitePrimary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorDefaults.whitePrimary),
      ),
      child: Column(
        children: [
          // --- ENCABEZADO MANUAL (REEMPLAZA AL CHARTTITLE) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlobalText(
                'Consumo de Agua (m³) : $selectedCol',
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
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlobalText(
                    'Promedio: ${promedio.toStringAsFixed(1)} m³',
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )
                  // Text(
                  //   'Promedio: ${promedio.toStringAsFixed(2)} m³',
                  //   style: const TextStyle(
                  //     color: Colors.orangeAccent,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 13,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 10),

          // --- GRÁFICO ---
          Expanded(
            child: SfCartesianChart(
              // Quitamos el title de aquí para usar el Row de arriba
              tooltipBehavior: TooltipBehavior(enable: true, header: selectedCol),
              zoomPanBehavior: ZoomPanBehavior(
                enablePanning: true,
                zoomMode: ZoomMode.x,
              ),
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: 14,
                autoScrollingMode: AutoScrollingMode.end,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  color: ColorDefaults.darkPrimary, 
                  fontSize: 12, 
                  fontWeight: FontWeight.bold
                ),
              ),
              primaryYAxis: NumericAxis(
                // title: AxisTitle(
                //   text: 'Consumo (m³)', 
                //   textStyle: TextStyle(color: ColorDefaults.darkPrimary, fontWeight: FontWeight.bold, fontSize: 10)
                // ),
                labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontWeight: FontWeight.bold),
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: promedio,
                    end: promedio,
                    borderWidth: 2,
                    borderColor: Colors.orangeAccent,
                    dashArray: <double>[6, 6],
                  )
                ],
              ),
              series: <CartesianSeries<dynamic, String>>[
                ColumnSeries<dynamic, String>(
                  name: selectedCol,
                  dataSource: widget.allData,
                  xValueMapper: (data, _) => data['fecha_operativa']?.toString() ?? '',
                  yValueMapper: (data, _) => data[selectedCol] ?? 0,
                  pointColorMapper: (data, _) {
                    final valor = data[selectedCol] ?? 0;
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
                      fontWeight: FontWeight.bold
                    )
                  ),
                  enableTooltip: true,
                  animationDuration: 800, 
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}