import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
class GraphManifoldWidget extends StatefulWidget {
  final List<dynamic> allData;
  const GraphManifoldWidget({super.key, required this.allData});

  @override
  State<GraphManifoldWidget> createState() => _GraphManifoldWidgetState();
}

class _GraphManifoldWidgetState extends State<GraphManifoldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12)
      ),
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          zoomMode: ZoomMode.x
        ),

        primaryXAxis: CategoryAxis(
          labelRotation: 45,
          autoScrollingDelta: 14,
          autoScrollingMode: AutoScrollingMode.end,
        ),

        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Grafico'),
          plotBands: <PlotBand>[
            PlotBand(
              isVisible: true,
              start: 12,
              borderWidth: 3,
              borderColor: Colors.orangeAccent,
              dashArray: <double>[6, 6],
              text: 'Promedio',
              horizontalTextAlignment: TextAnchor.end
            )
          ],
        ),
        series: <CartesianSeries<dynamic, String>>[
          ColumnSeries<dynamic, String>(
            name: 'Grafica',
            dataSource: widget.allData,
            xValueMapper: (data, _) => data['fecha_operativa'].toString(), 
              yValueMapper: (data, _) {
                // if (_campoGrafica == 'total') {
                //   return (data['CIP'] ?? 0) + (data['DesaireadorA'] ?? 0) + (data['DesaireadorB'] ?? 0) + (data['DesaireadorC'] ?? 0) + (data['Fuerza'] ?? 0) + (data['Lavadoras'] ?? 0) + (data['LineasPET'] ?? 0) + (data['Multimix'] ?? 0) + (data['Potable'] ?? 0) + (data['Quasy'] ?? 0) + (data['Servicios'] ?? 0) + (data['Contisiolv'] ?? 0);
                // }
                return data['CIP'] ?? 0;
              }
          )
        ],
      ),
    );
  }
}