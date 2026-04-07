import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart'; // Necesario para el tema

class TablaOsmosis extends StatefulWidget {
  final List<dynamic> osmosisData;
  const TablaOsmosis({super.key, required this.osmosisData});

  @override
  State<TablaOsmosis> createState() => _TablaOsmosisState();
}

class _TablaOsmosisState extends State<TablaOsmosis> {
  late _PozosDataSource _dataSource;

  @override
  void didUpdateWidget(TablaOsmosis  oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.osmosisData != widget.osmosisData){
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
      List<dynamic> sortedData = List.from(widget.osmosisData);
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
      width: double.infinity,
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
    _buildColumn('MF01_in', 'MF01_in', border),
    _buildColumn('MF01_out', 'MF01_out', border),
    _buildColumn('MF02_in', 'MF02_in', border),
    _buildColumn('MF02_out', 'MF02_out', border),
    _buildColumn('MF04_in', 'MF04_in', border),
    _buildColumn('MF04_out', 'MF04_out', border),
    _buildColumn('MF05_in', 'MF05_in', border),
    _buildColumn('MF05_out', 'MF05_out', border),
    _buildColumn('MF06_in', 'MF06_in', border),
    _buildColumn('MF06_out', 'MF06_out', border),
    // _buildColumn('total_estaciones', 'Total Pozos', border, isTotal: true)
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
          left: name == 'total_estaciones' ? border : BorderSide.none
        )
      ),
      child: GlobalText(label, fontWeight: FontWeight.bold, fontSize: 14, color: ColorDefaults.darkPrimary,),
    )
  );
}


class _PozosDataSource extends DataGridSource {
  _PozosDataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
      // final total = (item['cip_a'] ?? 0) + (item['cip_b'] ?? 0) + (item['cip_c'] ?? 0) + (item['cip_d'] ?? 0) + (item['cip_e'] ?? 0) + (item['cip_f'] ?? 0);
      
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'fecha', value: item['fecha_operativa'].toString()),
        DataGridCell<num>(columnName: 'MF01_in', value: item['MF01_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF01_out', value: item['MF01_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF02_in', value: item['MF02_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF02_out', value: item['MF02_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF04_in', value: item['MF04_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF04_out', value: item['MF04_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF05_in', value: item['MF05_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF05_out', value: item['MF05_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF06_in', value: item['MF06_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF06_out', value: item['MF06_out'] ?? 0),

        // DataGridCell<num>(columnName: 'total_estaciones', value: total),
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
        final bool isTotal = cell.columnName == 'total_estaciones';
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