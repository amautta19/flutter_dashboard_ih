import 'package:flutter/material.dart';
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
  // Paleta de colores — mismo esquema que WurBarGraphDiary
  static const Color _bgCard       = Color(0xFF1E1E2E);
  static const Color _bgCardBorder = Color(0xFF2E2E4E);
  static const Color _bgTooltip    = Color(0xFF2A2A3E);
  static const Color _cyan         = Color(0xFF00E5FF);
  static const Color _textPrimary  = Colors.white;
  static const Color _textMuted    = Color(0xFFB0B0C8);
  static const Color _gridLine     = Color(0x1FFFFFFF);
  static const Color _axisLine     = Color(0x33FFFFFF);

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
        color: _bgCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _bgCardBorder, width: 1),
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
            color: _cyan,
            fontSize: 14,
          ),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: 'Hora',
          color: _bgTooltip,
          textStyle: const TextStyle(
            color: _textPrimary,
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
          axisLine: const AxisLine(color: _axisLine, width: 1),
          labelStyle: const TextStyle(color: _textMuted, fontSize: 10),
          labelRotation: 0,
          labelIntersectAction: AxisLabelIntersectAction.hide,
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: const MajorGridLines(
            width: 0.5,
            color: _gridLine,
            dashArray: <double>[5, 5],
          ),
          axisLine: const AxisLine(color: _axisLine, width: 1),
          labelStyle: const TextStyle(color: _textMuted, fontSize: 10),
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
            yValueMapper: (data, _) =>
                data[filterElementProvider.getElement] ?? 0,
            color: _cyan,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            spacing: 0.2,
            width: 0.8,
            animationDuration: 800,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              borderRadius: 4,
              color: _bgTooltip.withOpacity(0.85),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
              labelAlignment: ChartDataLabelAlignment.outer,
            ),
          ),
        ],
      ),
    );
  }
}