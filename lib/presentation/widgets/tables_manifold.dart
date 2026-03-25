import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableManifoldWidget extends StatefulWidget {
  final List<dynamic> allData; // Lista obtenida de los datos 
  const TableManifoldWidget({super.key, required this.allData});

  @override
  State<TableManifoldWidget> createState() => _TableManifoldWidgetState();
}

class _TableManifoldWidgetState extends State<TableManifoldWidget> {
  late _ConsumoDataSource _dataSource;
  @override
  void initState() {
    super.initState();
    _dataSource = _ConsumoDataSource(data: List.from(widget.allData.reversed));
  }
  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    return SizedBox(
      height: windowSize.height * 0.4,
      width: windowSize.width * 0.6,
      child: SfDataGrid(
        source: _dataSource,
        columnWidthMode: ColumnWidthMode.fill, 
        columns: _getColumns()
      ),
    );
  }

}
List<GridColumn> _getColumns() {
  return [
    _buildColumn('fecha', 'Fecha'), _buildColumn('cip', 'CIP'), _buildColumn('desaireadorA', 'Des. A'), _buildColumn('desaireadorB', 'Des. B'),
    _buildColumn('desaireadorC', 'Des. C'), _buildColumn('fuerza', 'Fuerza'), _buildColumn('lavadoras', 'Lavadoras'), _buildColumn('lineasPET', 'Líneas PET'),
    _buildColumn('multimix', 'Multimix'), _buildColumn('potable', 'Potable'), _buildColumn('quasy', 'Quasy'), _buildColumn('servicios', 'Servicios'),
    _buildColumn('contisolv', 'Contisolv'), _buildColumn('total', 'Total Día', isTotal: true),
  ];
}

// Diseño de las cabeceras de la tabla
GridColumn _buildColumn(String name, String label, {bool isTotal = false}) {
  return GridColumn(
    columnName: name, 
    label: Container(
      alignment: Alignment.center, 
      // color: isTotal ? Colors.blueAccent.withOpacity(0.9) : Colors.transparent, 
      color: ColorDefaults.primaryBlue,
      child: GlobalText(label, fontWeight: FontWeight.bold, fontSize: 14, color: ColorDefaults.darkPrimary,),
    )
  );
}
// DataSource datos de la tabla
class _ConsumoDataSource extends DataGridSource {
  _ConsumoDataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
      // Medida total la suma de todas las columnas
      final total = (item['CIP'] ?? 0) + (item['DesaireadorA'] ?? 0) + (item['DesaireadorB'] ?? 0) + (item['DesaireadorC'] ?? 0) + (item['Fuerza'] ?? 0) + (item['Lavadoras'] ?? 0) + (item['LineasPET'] ?? 0) + (item['Multimix'] ?? 0) + (item['Potable'] ?? 0) + (item['Quasy'] ?? 0) + (item['Servicios'] ?? 0) + (item['Contisiolv'] ?? 0);
      
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'fecha', value: item['fecha_operativa'].toString()),
        DataGridCell<num>(columnName: 'cip', value: item['CIP'] ?? 0),
        DataGridCell<num>(columnName: 'desaireadorA', value: item['DesaireadorA'] ?? 0),
        DataGridCell<num>(columnName: 'desaireadorB', value: item['DesaireadorB'] ?? 0),
        DataGridCell<num>(columnName: 'desaireadorC', value: item['DesaireadorC'] ?? 0),
        DataGridCell<num>(columnName: 'fuerza', value: item['Fuerza'] ?? 0),
        DataGridCell<num>(columnName: 'lavadoras', value: item['Lavadoras'] ?? 0),
        DataGridCell<num>(columnName: 'lineasPET', value: item['LineasPET'] ?? 0),
        DataGridCell<num>(columnName: 'multimix', value: item['Multimix'] ?? 0),
        DataGridCell<num>(columnName: 'potable', value: item['Potable'] ?? 0),
        DataGridCell<num>(columnName: 'quasy', value: item['Quasy'] ?? 0),
        DataGridCell<num>(columnName: 'servicios', value: item['Servicios'] ?? 0),
        DataGridCell<num>(columnName: 'contisolv', value: item['Contisiolv'] ?? 0),
        DataGridCell<num>(columnName: 'total', value: total),
      ]);
    }).toList();
  }
  List<DataGridRow> _rows = [];
  @override List<DataGridRow> get rows => _rows;
  @override DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: row.getCells().map<Widget>((cell) {
      final bool isTotal = cell.columnName == 'total';
      return Container(
        alignment: Alignment.center, 
        padding: const EdgeInsets.all(8), 
        color: isTotal ? ColorDefaults.secundaryBlue : ColorDefaults.whitePrimary, 
        child: GlobalText(cell.value.toString(), fontSize: 12, color: ColorDefaults.darkPrimary,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
      );
    }).toList());
  }
}