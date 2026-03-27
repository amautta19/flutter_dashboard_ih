import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart'; // Necesario para el tema

class TablePozos extends StatefulWidget {
  final List<dynamic> pozosData;
  const TablePozos({super.key, required this.pozosData});

  @override
  State<TablePozos> createState() => _TablePozosState();
}

class _TablePozosState extends State<TablePozos> {
  late _PozosDataSource _dataSource;

  @override
  void didUpdateWidget(TablePozos  oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.pozosData != widget.pozosData){
      _actualizarDataSource();
    }
  }
  @override
  void initState() {
    super.initState();
    _actualizarDataSource();
  }
  
  void _actualizarDataSource(){
    setState(() {
      List<dynamic> sortedData = List.from(widget.pozosData);
      sortedData.sort((a,b){
        DateTime fechaA = DateTime.parse(a['fecha_operativa']);
        DateTime fechaB = DateTime.parse(b['fecha_operativa']);
        return fechaB.compareTo(fechaA);
      });
      _dataSource = _PozosDataSource(data: sortedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final BorderSide customBorder = BorderSide(
      color: ColorDefaults.darkPrimary.withOpacity(0.5),
      width: 2.5
    );
    return SizedBox(
      height: windowSize.height * 0.35,
      width: windowSize.width * 0.7,
      child: SfDataGridTheme(
        // Aplicamos el grosor y color a las líneas horizontales nativas
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
List<GridColumn> _getColumns(BorderSide border){
  return [
    _buildColumn('fecha', 'Fecha', border),
    _buildColumn('pozo1', 'Pozo 1', border),
    _buildColumn('pozo3', 'Pozo 3', border),
    _buildColumn('total_pozos', 'Total Pozos', border, isTotal: true)
  ];
}

GridColumn _buildColumn(String name, String label, BorderSide border, {bool isTotal = false}){
  return GridColumn(
    columnName: name, 
    label: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorDefaults.primaryBlue,
        border: Border(
          right: name == 'fecha' ? border : BorderSide.none,
          left: name == 'total_pozos' ? border : BorderSide.none
        )
      ),
      child: GlobalText(label, fontWeight: FontWeight.bold, fontSize: 14, color: ColorDefaults.darkPrimary,),
    )
  );
}


class _PozosDataSource extends DataGridSource {
  _PozosDataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
      final total = (item['Pozo1'] ?? 0) + (item['Pozo3'] ?? 0);
      
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'fecha', value: item['fecha_operativa'].toString()),
        DataGridCell<num>(columnName: 'pozo1', value: item['Pozo1'] ?? 0),
        DataGridCell<num>(columnName: 'pozo3', value: item['Pozo3'] ?? 0),
        DataGridCell<num>(columnName: 'total_pozos', value: total),
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
        final bool isTotal = cell.columnName == 'total_pozos';
        final bool isFecha = cell.columnName == 'fecha';

        return Container(
          alignment: Alignment.center, 
          padding: const EdgeInsets.symmetric(horizontal: 8), 
          decoration: BoxDecoration(
            color: isTotal ? ColorDefaults.secundaryBlue : Colors.transparent,
            border: Border(
              right: isFecha ? customBorder : BorderSide.none,
              left: isTotal ? customBorder : BorderSide.none,
            ),
          ),
          child: GlobalText(cell.value.toString(), fontSize: 12, color: ColorDefaults.darkPrimary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
        );
      }).toList(),
    );
  }
}