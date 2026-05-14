import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TableWurMensual extends StatefulWidget {
  final List<dynamic> allData; 
  const TableWurMensual({super.key, required this.allData});

  @override
  State<TableWurMensual> createState() => _TableWurMensualState();
}

class _TableWurMensualState extends State<TableWurMensual> {
  late _ConsumoDataSource _dataSource;
  
  @override
  void didUpdateWidget(TableWurMensual oldWidget) {
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
        DateTime fechaA = DateTime.parse(a['mes_inicio'] ?? DateTime.now().toString());
        DateTime fechaB = DateTime.parse(b['mes_inicio'] ?? DateTime.now().toString());
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
      height: windowSize.height * 0.3,
      width: windowSize.width * 0.3,
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
    _buildColumn('mes', 'Mes', border), 
    _buildColumn('bebida_total', 'Bebida', border), 
    _buildColumn('pozos_total', 'Pozos', border), 
    _buildColumn('wur_mensual', 'WUR', border), 

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
          columnName: 'mes', 
          value: item['mes_label']?.toString() ?? 'N/A'
        ),
        // La fecha de inicio de la semana (String)
        DataGridCell<double>(
          columnName: 'bebida_total', 
          value: (item['total_m3_bebida_mensual'] as num?)?.toDouble() ?? 0.0
        ),
        // El valor numérico del WUR
        DataGridCell<double>(
          columnName: 'pozos_total', 
          value: (item['tota_pozos_mensual'] as num?)?.toDouble() ?? 0.0
        ),
        DataGridCell<double>(
          columnName: 'wur_mensual', 
          value: (item['wur_mensual'] as num?)?.toDouble() ?? 0.0
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
        final bool isWur = cell.columnName == 'wur_mensual';
        final bool isFecha = cell.columnName == 'mes';

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