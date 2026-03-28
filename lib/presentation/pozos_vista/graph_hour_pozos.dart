import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphHourPozos extends StatelessWidget {
  final List<dynamic> pozosData;
  const GraphHourPozos({super.key, required this.pozosData});

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;
    final filterElementProvider = Provider.of<FilterElementProvider>(context);

    return Container(
      height: windowsSize.height * 0.42,
      width: windowsSize.width * 0.38,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: ColorDefaults.whitePrimary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SfCartesianChart(
        title: ChartTitle(
          text: 'Evolución Temporal: ${filterElementProvider.getElement}',
          alignment: ChartAlignment.near,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold, 
            color: ColorDefaults.primaryBlue,
            fontSize: 14
          )
        ),
        
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: 'Hora', // Cambiado para que coincida con el eje
        ),

        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          zoomMode: ZoomMode.x,
        ),

        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 12),
          labelRotation: 0, // Labels horizontales
          labelIntersectAction: AxisLabelIntersectAction.hide, // Oculta si chocan
          interval: null, 
        ),

        primaryYAxis: NumericAxis(
          majorGridLines: const MajorGridLines(
            width: 0.5,
            dashArray: <double>[5, 5],
          ),
          labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 12),
        ),

        series: <CartesianSeries<dynamic, String>>[
          ColumnSeries<dynamic, String>(
            name: filterElementProvider.getElement,
            dataSource: pozosData,
            // --- EXTRACCIÓN DE LA HORA ---
            xValueMapper: (data, _) {
              final fullTime = data['_time_lima']?.toString() ?? '';
              // Si el formato es '2026-03-25 14:30:00', esto devuelve '14:30'
              if (fullTime.length >= 16) {
                return fullTime.substring(11, 16); 
              }
              return fullTime;
            },
            yValueMapper: (data, _) => data[filterElementProvider.getElement] ?? 0,
            color: ColorDefaults.primaryBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            spacing: 0.2,
            width: 0.8,
            animationDuration: 1000,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: ColorDefaults.darkPrimary
              ),
              labelAlignment: ChartDataLabelAlignment.outer
            ),
          )
        ],
      ),
    );
  }
}