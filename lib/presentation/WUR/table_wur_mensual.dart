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
    this.width = 0.25
  });

  @override
  State<TableWurMonthly> createState() => _TableWurMonthlyState();
}

class _TableWurMonthlyState extends State<TableWurMonthly> {

  _DataSource _dataSource = _DataSource(data: []);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _actualizarDataSource());
  }

  @override
  void didUpdateWidget(covariant TableWurMonthly oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(oldWidget.allData != widget.allData){
      _actualizarDataSource();
    }
  }

  void _actualizarDataSource(){
    if(!mounted) return;
    setState(() {
      List<dynamic> sortedData = List.from(widget.allData);
      _dataSource = _DataSource(data: sortedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GlobalText('WUR Mensual', fontSize: 18, color: ColorDefaults.secundaryBlue, fontWeight: FontWeight.bold,),
        SizedBox(
          height: windowSize.height * widget.heiht,
          width: windowSize.width * widget.width,
          child: SfDataGridTheme(
            data: SfDataGridThemeData(
              gridLineColor: ColorDefaults.darkPrimary.withOpacity(0.5),
              gridLineStrokeWidth: 2.5
            ), 
            child: SfDataGrid(
              source: _dataSource, 
              columnWidthMode: ColumnWidthMode.fill,
              gridLinesVisibility: GridLinesVisibility.horizontal,
              headerGridLinesVisibility: GridLinesVisibility.horizontal,
              columns: _getColumns(),
            )
          )
        ),
      ],
    );
  }
}
List<GridColumn> _getColumns(){
  return [
    _buildColumn('mes', 'Mes'),
    // _buildColumn('tota_bebida', 'Total Bebida'),
    // _buildColumn('total_pozos', 'Total Pozos'),
    _buildColumn('wur', 'WUR')
  ];
}
GridColumn _buildColumn(String name, String label){
  return GridColumn(
    columnName: name, 
    label: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: ColorDefaults.primaryBlue),
      child: GlobalText(
        label,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: ColorDefaults.darkPrimary,
      ),
    )
  );
}
class _DataSource extends DataGridSource{
  
  _DataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'mes', 
          value: item['mes_label']?.toString() ?? 'N/A'
        ),
        // DataGridCell<double>(
        //   columnName: 'total_bebida', 
        //   value: (item['total_m3_bebida_mensual'] as num?)?.toDouble() ?? 0.0
        // ),
        // DataGridCell<double>(
        //   columnName: 'total_pozos', 
        //   value: (item['total_pozos_mensual'] as num?)?.toDouble() ?? 0.0
        // ),
        DataGridCell<double>(
          columnName: 'wur', 
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
      cells: row.getCells().map<Widget>((cell){
        final bool isWur = cell.columnName == 'wur';
        Color cellBackgroundColor = ColorDefaults.whitePrimary;
        Color textColor = ColorDefaults.darkPrimary;
        if(isWur){
          double valorCelda = (cell.value as num).toDouble();
          cellBackgroundColor = valorCelda > 1.55
            ? Colors.redAccent.withOpacity(0.9)
            : Colors.greenAccent.withOpacity(0.9);
        }
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: cellBackgroundColor,
            border: Border(
              left: isWur ? customBorder : BorderSide.none
            )
          ),
          child: GlobalText(
            cell.value.toString(),
            fontSize: 12,
            color: textColor,
            fontWeight: isWur ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList()
    );
  }
  
}