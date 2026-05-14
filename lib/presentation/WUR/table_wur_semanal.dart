import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TableWurSemanal extends StatefulWidget {
  final List<dynamic> allData; 
  const TableWurSemanal({super.key, required this.allData});

  @override
  State<TableWurSemanal> createState() => _TableWurSemanalState();
}

class _TableWurSemanalState extends State<TableWurSemanal> {
  late _ConsumoDataSource _dataSource;
  
  @override
  void didUpdateWidget(TableWurSemanal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.allData != widget.allData){
      _actualizarDataSource();
    }
  }

  void _actualizarDataSource() {
    setState(() {
      List<dynamic> sortedData = List.from(widget.allData);
      // Ordenamos por fecha de inicio descendente (la más reciente arriba)
      sortedData.sort((a, b) {
        DateTime fechaA = DateTime.parse(a['semana_inicio'] ?? DateTime.now().toString());
        DateTime fechaB = DateTime.parse(b['semana_inicio'] ?? DateTime.now().toString());
        return fechaB.compareTo(fechaA);
      });
      _dataSource = _ConsumoDataSource(data: sortedData);
    });
  }

  @override
  void initState() {
    super.initState();
    _actualizarDataSource();
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    
    final BorderSide customBorder = BorderSide(
      color: ColorDefaults.darkPrimary.withOpacity(0.5), 
      width: 2.5
    );

    return SizedBox(
      // height: windowSize.height * 0.35,
      width: windowSize.width * 0.7,
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          gridLineColor: ColorDefaults.darkPrimary.withOpacity(0.5),
          gridLineStrokeWidth: 2.5,
        ),
        child: SfDataGrid(
          source: _dataSource,
          columnWidthMode: ColumnWidthMode.fill, 
          gridLinesVisibility: GridLinesVisibility.horizontal,
          headerGridLinesVisibility: GridLinesVisibility.horizontal,
          columns: _getColumns(customBorder),
        ),
      ),
    );
  }
}

List<GridColumn> _getColumns(BorderSide border) {
  return [
    _buildColumn('semana', 'Semana', border), 
    _buildColumn('fecha_inicio', 'Fecha Inicio', border), 
    _buildColumn('wur_semanal', 'WUR', border), 
  ];
}

GridColumn _buildColumn(String name, String label, BorderSide border) {
  return GridColumn(
    columnName: name, 
    label: Container(
      alignment: Alignment.center, 
      decoration: BoxDecoration(
        color: ColorDefaults.primaryBlue,
      ),
      child: GlobalText(
        label, 
        fontWeight: FontWeight.bold, 
        fontSize: 14, 
        color: ColorDefaults.darkPrimary,
      ),
    )
  );
}

class _ConsumoDataSource extends DataGridSource {
  _ConsumoDataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        // La etiqueta "Semana X"
        DataGridCell<String>(
          columnName: 'semana', 
          value: item['semana_label']?.toString() ?? 'N/A'
        ),
        // La fecha de inicio de la semana (String)
        DataGridCell<String>(
          columnName: 'fecha_inicio', 
          value: item['semana_inicio']?.toString() ?? 'N/A'
        ),
        // El valor numérico del WUR
        DataGridCell<double>(
          columnName: 'wur_semanal', 
          value: (item['wur_semanal'] as num?)?.toDouble() ?? 0.0
        ),
      ]);
    }).toList();
  }

  List<DataGridRow> _rows = [];
  @override List<DataGridRow> get rows => _rows;
  
  @override 
  DataGridRowAdapter buildRow(DataGridRow row) {
    final BorderSide customBorder = BorderSide(
      color: ColorDefaults.darkPrimary.withOpacity(0.5), 
      width: 1.5
    );

    return DataGridRowAdapter(
      color: ColorDefaults.whitePrimary,
      cells: row.getCells().map<Widget>((cell) {
        final bool isWur = cell.columnName == 'wur_semanal';
        final bool isFecha = cell.columnName == 'fecha_inicio';

        return Container(
          alignment: Alignment.center, 
          padding: const EdgeInsets.symmetric(horizontal: 8), 
          decoration: BoxDecoration(
            // Resaltamos la columna del WUR
            color: isWur ? ColorDefaults.secundaryBlue.withOpacity(0.3) : Colors.transparent,
            border: Border(
              right: isFecha ? customBorder : BorderSide.none,
              left: isWur ? customBorder : BorderSide.none,
            ),
          ),
          child: GlobalText(
            cell.value.toString(), 
            fontSize: 12, 
            color: ColorDefaults.darkPrimary,
            fontWeight: isWur ? FontWeight.bold : FontWeight.normal
          ),
        );
      }).toList(),
    );
  }
}