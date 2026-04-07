import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart'; // Necesario para el tema

class TablaFiltrosPulidores extends StatefulWidget {
  final List<dynamic> cipData;
  const TablaFiltrosPulidores({super.key, required this.cipData});

  @override
  State<TablaFiltrosPulidores> createState() => _TablaFiltrosPulidoresState();
}

class _TablaFiltrosPulidoresState extends State<TablaFiltrosPulidores> {
  late _FiltrosDataSource _dataSource;

  @override
  void didUpdateWidget(TablaFiltrosPulidores  oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.cipData != widget.cipData){
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
      List<dynamic> sortedData = List.from(widget.cipData);
      sortedData.sort((a,b){
        DateTime fechaA = DateTime.parse(a['fecha_operativa']);
        DateTime fechaB = DateTime.parse(b['fecha_operativa']);
        return fechaB.compareTo(fechaA);
      });
      _dataSource = _FiltrosDataSource(data: sortedData);
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
    _buildColumn('AF01', 'AF01', border),
    _buildColumn('AF02', 'AF02', border),
    _buildColumn('AF03', 'AF03', border),
    _buildColumn('AF04', 'AF04', border),
    _buildColumn('AF05', 'AF05', border),
    _buildColumn('AF06', 'AF06', border),
    _buildColumn('KF09', 'KF09', border),
    _buildColumn('KF10', 'KF10', border),

    _buildColumn('total_filtros', 'Total', border, isTotal: true)
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
          left: name == 'total_filtros' ? border : BorderSide.none
        )
      ),
      child: GlobalText(label, fontWeight: FontWeight.bold, fontSize: 14, color: ColorDefaults.darkPrimary,),
    )
  );
}


class _FiltrosDataSource extends DataGridSource {
  _FiltrosDataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
      final total = (item['AF01'] ?? 0) + (item['AF02'] ?? 0) + (item['AF03'] ?? 0) + (item['AF04'] ?? 0) + (item['AF05'] ?? 0) + (item['AF06'] ?? 0) + (item['KF09'] ?? 0) + (item['KF10'] ?? 0);
      
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'fecha', value: item['fecha_operativa'].toString()),
        DataGridCell<num>(columnName: 'AF01', value: item['AF01'] ?? 0),
        DataGridCell<num>(columnName: 'AF02', value: item['AF02'] ?? 0),
        DataGridCell<num>(columnName: 'AF03', value: item['AF03'] ?? 0),
        DataGridCell<num>(columnName: 'AF04', value: item['AF04'] ?? 0),
        DataGridCell<num>(columnName: 'AF05', value: item['AF05'] ?? 0),
        DataGridCell<num>(columnName: 'AF06', value: item['AF06'] ?? 0),
        DataGridCell<num>(columnName: 'KF09', value: item['KF09'] ?? 0),
        DataGridCell<num>(columnName: 'KF10', value: item['KF10'] ?? 0),

        DataGridCell<num>(columnName: 'total_filtros', value: total),
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
        final bool isTotal = cell.columnName == 'total_filtros';
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