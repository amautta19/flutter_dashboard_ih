import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
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
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GlobalText(
            'WUR Mensual',
            fontSize: 16,
            color: ColorDefaults.secundaryBlue,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SfDataGridTheme(
              data: SfDataGridThemeData(
                gridLineColor: ColorDefaults.darkGridLine,
                gridLineStrokeWidth: 1,
                headerColor: ColorDefaults.darkBgHeader,
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
      decoration: BoxDecoration(
        color: ColorDefaults.darkBgHeader,
        border: Border(
          bottom: BorderSide(color: ColorDefaults.darkCyan, width: 2),
        ),
      ),
      child: GlobalText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: ColorDefaults.darkCyan,
      ),
    ),
  );
}

class _DataSource extends DataGridSource {

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
    final int index = _rows.indexOf(row);
    final Color rowBg = index.isOdd ? ColorDefaults.darkBgCardAlt : ColorDefaults.darkBgCard;

    return DataGridRowAdapter(
      color: rowBg,
      cells: row.getCells().map<Widget>((cell) {
        final bool isWur = cell.columnName == 'wur';

        Color cellBg = Colors.transparent;

        if (isWur) {
          final double valor = (cell.value as num).toDouble();
          cellBg = valor > 1.55
              ? ColorDefaults.darkBarBad.withOpacity(0.85)
              : ColorDefaults.darkBarGood.withOpacity(0.85);
        }

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: cellBg,
            border: Border(
              bottom: BorderSide(color: ColorDefaults.darkGridLine, width: 1),
              left: isWur
                  ? BorderSide(color: ColorDefaults.darkGridLine, width: 1)
                  : BorderSide.none,
            ),
          ),
          child: GlobalText(
            cell.value.toString(),
            fontSize: 12,
            color: ColorDefaults.darkTextPrimary,
            fontWeight: isWur ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}