import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TableWurSemanal extends StatefulWidget {
  final List<dynamic> allData;
  const TableWurSemanal({super.key, required this.allData});

  @override
  State<TableWurSemanal> createState() => _TableWurSemanalState();
}

class _TableWurSemanalState extends State<TableWurSemanal> {
  // Paleta de colores — mismo esquema que el resto
  static const Color _bgCard       = Color(0xFF1E1E2E);
  static const Color _bgCardBorder = Color(0xFF2E2E4E);
  static const Color _bgHeader     = Color(0xFF2A2A3E);
  static const Color _bgRow        = Color(0xFF1E1E2E);
  static const Color _bgRowAlt     = Color(0xFF232336);
  static const Color _cyan         = Color(0xFF00E5FF);
  static const Color _textMuted    = Color(0xFFB0B0C8);
  static const Color _gridLine     = Color(0x1FFFFFFF);
  static const Color _barGood      = Color(0xFF4CAF50);
  static const Color _barBad       = Color(0xFFE53935);

  _ConsumoDataSource _dataSource = _ConsumoDataSource(data: [], umbralReferencia: 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _actualizarDataSource());
  }

  @override
  void didUpdateWidget(TableWurSemanal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _actualizarDataSource();
    }
  }

  void _actualizarDataSource() {
    if (!mounted) return;

    final umbralesProvider = context.read<UmbralesProvider>();
    final umbralMap = umbralesProvider.tablaUmbrales.firstWhere(
      (elemento) => elemento['argumento'] == 'wur',
      orElse: () => {'umbral': 1.52},
    );

    double valorWurRef = (umbralMap['umbral'] as num).toDouble();

    setState(() {
      List<dynamic> sortedData = List.from(widget.allData);
      if (sortedData.isNotEmpty) {
        sortedData.sort((a, b) {
          DateTime fechaA = DateTime.parse(a['semana_inicio'] ?? DateTime.now().toString());
          DateTime fechaB = DateTime.parse(b['semana_inicio'] ?? DateTime.now().toString());
          return fechaB.compareTo(fechaA);
        });
      }
      _dataSource = _ConsumoDataSource(
        data: sortedData,
        umbralReferencia: valorWurRef,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * 0.35,
      width: windowSize.width * 0.15,
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Título ───────────────────────────────────────────────
          GlobalText(
            'WUR - Semanal',
            fontSize: 16,
            color: _cyan,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),

          Expanded(
            child: SfDataGridTheme(
              data: SfDataGridThemeData(
                gridLineColor: _gridLine,
                gridLineStrokeWidth: 1,
                headerColor: _bgHeader,
              ),
              child: SfDataGrid(
                source: _dataSource,
                columnWidthMode: ColumnWidthMode.fill,
                gridLinesVisibility: GridLinesVisibility.horizontal,
                headerGridLinesVisibility: GridLinesVisibility.horizontal,
                columns: _getColumns(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<GridColumn> _getColumns() {
  return [
    _buildColumn('semana', 'Semana'),
    _buildColumn('wur_semanal', 'WUR'),
  ];
}

GridColumn _buildColumn(String name, String label) {
  return GridColumn(
    columnName: name,
    label: Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A3E),
        border: Border(
          bottom: BorderSide(color: Color(0xFF00E5FF), width: 2),
        ),
      ),
      child: GlobalText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00E5FF),
      ),
    ),
  );
}

class _ConsumoDataSource extends DataGridSource {
  static const Color _bgRow    = Color(0xFF1E1E2E);
  static const Color _bgRowAlt = Color(0xFF232336);
  static const Color _gridLine = Color(0x1FFFFFFF);
  static const Color _barGood  = Color(0xFF4CAF50);
  static const Color _barBad   = Color(0xFFE53935);

  final double umbralReferencia;

  _ConsumoDataSource({required List<dynamic> data, required this.umbralReferencia}) {
    _rows = data.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'semana',
          value: item['semana_label']?.toString() ?? 'N/A',
        ),
        DataGridCell<double>(
          columnName: 'wur_semanal',
          value: (item['wur_semanal'] as num?)?.toDouble() ?? 0.0,
        ),
      ]);
    }).toList();
  }

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int index = _rows.indexOf(row);
    final Color rowBg = index.isOdd ? _bgRowAlt : _bgRow;

    return DataGridRowAdapter(
      color: rowBg,
      cells: row.getCells().map<Widget>((cell) {
        final bool isWur = cell.columnName == 'wur_semanal';

        Color cellBg = Colors.transparent;
        Color textColor = const Color(0xFFB0B0C8); // _textMuted

        if (isWur) {
          final double valor = (cell.value as num).toDouble();
          cellBg = valor > umbralReferencia
              ? _barBad.withOpacity(0.85)
              : _barGood.withOpacity(0.85);
          textColor = Colors.white;
        }

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: cellBg,
            border: Border(
              bottom: BorderSide(color: _gridLine, width: 1),
              left: isWur
                  ? const BorderSide(color: Color(0x1FFFFFFF), width: 1)
                  : BorderSide.none,
            ),
          ),
          child: GlobalText(
            cell.value.toString(),
            fontSize: 12,
            color: textColor,
            fontWeight: isWur ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}