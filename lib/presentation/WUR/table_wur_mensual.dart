import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableWurMonthly extends StatefulWidget {
  final List<dynamic> allData;
  final double heiht;
  final double width;
  const TableWurMonthly({
    super.key,
    required this.allData,
    this.heiht = 0.35,
    this.width = 0.25,
  });

  @override
  State<TableWurMonthly> createState() => _TableWurMonthlyState();
}

class _TableWurMonthlyState extends State<TableWurMonthly> {
  // Paleta de colores — mismo esquema que los gráficos
  static const Color _bgCard       = Color(0xFF1E1E2E);
  static const Color _bgCardBorder = Color(0xFF2E2E4E);
  static const Color _bgHeader     = Color(0xFF2A2A3E);
  static const Color _bgRow        = Color(0xFF1E1E2E);
  static const Color _bgRowAlt     = Color(0xFF232336);
  static const Color _cyan         = Color(0xFF00E5FF);
  static const Color _textPrimary  = Colors.white;
  static const Color _textMuted    = Color(0xFFB0B0C8);
  static const Color _gridLine     = Color(0x1FFFFFFF);
  static const Color _barGood      = Color(0xFF4CAF50);
  static const Color _barBad       = Color(0xFFE53935);

  _DataSource _dataSource = _DataSource(data: []);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _actualizarDataSource());
  }

  @override
  void didUpdateWidget(covariant TableWurMonthly oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _actualizarDataSource();
    }
  }

  void _actualizarDataSource() {
    if (!mounted) return;
    setState(() {
      List<dynamic> sortedData = List.from(widget.allData);
      if (sortedData.isNotEmpty) {
        sortedData.sort((a, b) {
          DateTime fechaA = DateTime.parse(a['mes_inicio'] ?? DateTime.now().toString());
          DateTime fechaB = DateTime.parse(b['mes_inicio'] ?? DateTime.now().toString());
          return fechaB.compareTo(fechaA);
        });
      }
      _dataSource = _DataSource(data: sortedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return Container(
      height: windowSize.height * widget.heiht,
      width: windowSize.width * widget.width,
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
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Título ───────────────────────────────────────────────
          GlobalText(
            'WUR Mensual',
            fontSize: 16,
            color: _cyan,
            fontWeight: FontWeight.bold,
          ),
          // const SizedBox(height: 10),
          const SizedBox(height: 10,),
          // ── Tabla ────────────────────────────────────────────────
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
    _buildColumn('mes', 'Mes'),
    _buildColumn('wur', 'WUR'),
  ];
}

GridColumn _buildColumn(String name, String label) {
  return GridColumn(
    columnName: name,
    label: Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A3E), // _bgHeader
        border: Border(
          bottom: BorderSide(color: Color(0xFF00E5FF), width: 2), // línea cyan debajo del header
        ),
      ),
      child: GlobalText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00E5FF), // _cyan
      ),
    ),
  );
}

class _DataSource extends DataGridSource {
  static const Color _bgRow    = Color(0xFF1E1E2E);
  static const Color _bgRowAlt = Color(0xFF232336);
  static const Color _gridLine = Color(0x1FFFFFFF);
  static const Color _barGood  = Color(0xFF4CAF50);
  static const Color _barBad   = Color(0xFFE53935);

  _DataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'mes',
          value: item['mes_label']?.toString() ?? 'N/A',
        ),
        DataGridCell<double>(
          columnName: 'wur',
          value: (item['wur_mensual'] as num?)?.toDouble() ?? 0.0,
        ),
      ]);
    }).toList();
  }

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    // Índice para filas alternas
    final int index = _rows.indexOf(row);
    final Color rowBg = index.isOdd ? _bgRowAlt : _bgRow;

    return DataGridRowAdapter(
      color: rowBg,
      cells: row.getCells().map<Widget>((cell) {
        final bool isWur = cell.columnName == 'wur';

        Color cellBg = Colors.transparent;
        Color textColor = const Color(0xFFB0B0C8); // _textMuted

        if (isWur) {
          final double valor = (cell.value as num).toDouble();
          cellBg = valor > 1.55
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
            color: Colors.white,
            fontWeight: isWur ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}