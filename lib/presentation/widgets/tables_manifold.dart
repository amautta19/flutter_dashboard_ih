import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart'; // Necesario para el tema

class TableManifoldWidget extends StatefulWidget {
  final List<dynamic> allData; 
  const TableManifoldWidget({super.key, required this.allData});

  @override
  State<TableManifoldWidget> createState() => _TableManifoldWidgetState();
}

class _TableManifoldWidgetState extends State<TableManifoldWidget> {
  late _ConsumoDataSource _dataSource;
  
  @override
  void didUpdateWidget(TableManifoldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.allData != widget.allData){
      _actualizarDataSource();
    }
  }

  void _actualizarDataSource() {
    setState(() {
      List<dynamic> sortedData = List.from(widget.allData);
      sortedData.sort((a, b) {
        DateTime fechaA = DateTime.parse(a['fecha_operativa']);
        DateTime fechaB = DateTime.parse(b['fecha_operativa']);
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
    
    // Definimos el estilo de línea común
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

List<GridColumn> _getColumns(BorderSide border) {
  return [
    _buildColumn('fecha', 'Fecha', border), 
    _buildColumn('cip', 'CIP', border), 
    _buildColumn('desaireadorA', 'Des. A', border), 
    _buildColumn('desaireadorB', 'Des. B', border),
    _buildColumn('desaireadorC', 'Des. C', border), 
    _buildColumn('fuerza', 'Fuerza', border), 
    _buildColumn('lavadoras', 'Lavadoras', border), 
    _buildColumn('lineasPET', 'Líneas PET', border),
    _buildColumn('multimix', 'Multimix', border), 
    _buildColumn('potable', 'Potable', border), 
    _buildColumn('quasy', 'Quasy', border), 
    _buildColumn('servicios', 'Servicios', border),
    _buildColumn('contisolv', 'Contisolv', border), 
    _buildColumn('total', 'Total Día', border, isTotal: true),
  ];
}

GridColumn _buildColumn(String name, String label, BorderSide border, {bool isTotal = false}) {
  return GridColumn(
    columnName: name, 
    label: Container(
      alignment: Alignment.center, 
      decoration: BoxDecoration(
        color: ColorDefaults.primaryBlue,
        border: Border(
          right: name == 'fecha' ? border : BorderSide.none,
          left: name == 'total' ? border : BorderSide.none,
        ),
      ),
      child: GlobalText(label, fontWeight: FontWeight.bold, fontSize: 14, color: ColorDefaults.darkPrimary,),
    )
  );
}

class _ConsumoDataSource extends DataGridSource {
  _ConsumoDataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
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
  
  @override 
  DataGridRowAdapter buildRow(DataGridRow row) {
    final BorderSide customBorder = BorderSide(
      color: ColorDefaults.darkPrimary.withOpacity(0.5), 
      width: 1.5
    );

    return DataGridRowAdapter(
      color: ColorDefaults.whitePrimary,
      cells: row.getCells().map<Widget>((cell) {
        final bool isTotal = cell.columnName == 'total';
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