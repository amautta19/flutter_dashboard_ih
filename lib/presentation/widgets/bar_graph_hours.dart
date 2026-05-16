import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarGraphHours extends StatefulWidget {
  final List<dynamic> allData;
  final double widthGraph;
  const BarGraphHours({
    super.key,
    required this.allData,
    this.widthGraph = 0.38,
  });

  @override
  State<BarGraphHours> createState() => _BarGraphHoursState();
}

class _BarGraphHoursState extends State<BarGraphHours> {
  List<dynamic> _currentData = [];

  @override
  void initState() {
    super.initState();
    _currentData = widget.allData;
  }

  @override
  void didUpdateWidget(BarGraphHours oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      setState(() {
        _currentData = widget.allData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final windowsSize = MediaQuery.of(context).size;
    final filterElementProvider = context.watch<FilterElementProvider>();

    return Container(
      height: windowsSize.height * 0.42,
      width: windowsSize.width * widget.widthGraph,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorDefaults.darkBgCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorDefaults.darkBgBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SfCartesianChart(
        backgroundColor: Colors.transparent,
        plotAreaBackgroundColor: Colors.transparent,
        title: ChartTitle(
          text: 'Evolución Temporal: ${filterElementProvider.getElement}',
          alignment: ChartAlignment.near,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorDefaults.darkCyan,
            fontSize: 14,
          ),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: 'Hora',
          color: ColorDefaults.darkBgHeader,
          textStyle: const TextStyle(
            color: ColorDefaults.darkTextPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          activationMode: ActivationMode.singleTap,
          duration: 150,
        ),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          zoomMode: ZoomMode.x,
        ),
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
          labelStyle: const TextStyle(color: ColorDefaults.darkTextMuted, fontSize: 10),
          labelRotation: 0,
          labelIntersectAction: AxisLabelIntersectAction.hide,
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: const MajorGridLines(
            width: 0.5,
            color: ColorDefaults.darkGridLine,
            dashArray: <double>[5, 5],
          ),
          axisLine: const AxisLine(color: ColorDefaults.darkAxisLine, width: 1),
          labelStyle: const TextStyle(color: ColorDefaults.darkTextMuted, fontSize: 10),
        ),
        series: <CartesianSeries<dynamic, String>>[
          ColumnSeries<dynamic, String>(
            name: filterElementProvider.getElement,
            dataSource: _currentData,
            xValueMapper: (data, _) {
              final fullTime = data['_time_lima']?.toString() ?? '';
              if (fullTime.length >= 16) {
                return fullTime.substring(11, 16);
              }
              return fullTime;
            },
            yValueMapper: (data, _) => data[filterElementProvider.getElement] ?? 0,
            color: ColorDefaults.darkCyan,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            spacing: 0.2,
            width: 0.8,
            animationDuration: 800,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              borderRadius: 4,
              color: ColorDefaults.darkBgHeader.withOpacity(0.85),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: ColorDefaults.darkTextPrimary,
              ),
              labelAlignment: ChartDataLabelAlignment.outer,
            ),
          ),
        ],
      ),
    );
  }
}