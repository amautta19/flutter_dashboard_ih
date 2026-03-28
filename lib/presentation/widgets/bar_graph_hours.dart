import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarGraphHours extends StatefulWidget {
  final List<dynamic> allData;
  const BarGraphHours({super.key, required this.allData});

  @override
  State<BarGraphHours> createState() => _BarGraphHoursState();
}

class _BarGraphHoursState extends State<BarGraphHours> {
  // Guardamos la data procesada en el estado
  List<dynamic> _currentData = [];

  @override
  void initState() {
    super.initState();
    _currentData = widget.allData;
  }

  @override
  void didUpdateWidget(BarGraphHours oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizamos si la lista de datos realmente cambió
    if (oldWidget.allData != widget.allData) {
      setState(() {
        _currentData = widget.allData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;
    // Usamos watch aquí para que reaccione cuando cambies el filtro (CIP, Pozos, etc)
    final filterElementProvider = context.watch<FilterElementProvider>();

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
          header: 'Hora',
          activationMode: ActivationMode.singleTap,
          duration: 150, // Que desaparezca rápido
        ),

        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          zoomMode: ZoomMode.x,
        ),

        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: TextStyle(color: ColorDefaults.darkPrimary, fontSize: 12),
          labelRotation: 0,
          labelIntersectAction: AxisLabelIntersectAction.hide,
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
            dataSource: _currentData, // Usamos la data del estado
            xValueMapper: (data, _) {
              final fullTime = data['_time_lima']?.toString() ?? '';
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
            animationDuration: 800, // Animación sutil al cambiar valores
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                fontSize: 11, // Un poco más pequeño para que no se amontone
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