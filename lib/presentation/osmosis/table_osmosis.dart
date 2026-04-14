import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart'; // Importante
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TablaOsmosis extends StatefulWidget {
  final List<dynamic> osmosisData;
  const TablaOsmosis({super.key, required this.osmosisData});

  @override
  State<TablaOsmosis> createState() => _TablaOsmosisState();
}

class _TablaOsmosisState extends State<TablaOsmosis> {
  late _PozosDataSource _dataSource;

  @override
  void didUpdateWidget(TablaOsmosis oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.osmosisData != widget.osmosisData) {
      _actualizarDataSource();
    }
  }

  @override
  void initState() {
    super.initState();
    _actualizarDataSource();
  }

  void _actualizarDataSource() {
    // Obtenemos la tabla de umbrales del provider (listen false porque estamos en un método)
    final listaUmbrales = Provider.of<UmbralesProvider>(context, listen: false).tablaUmbrales;

    setState(() {
      List<dynamic> sortedData = List.from(widget.osmosisData);
      sortedData.sort((a, b) {
        DateTime fechaA = DateTime.parse(a['fecha_operativa']);
        DateTime fechaB = DateTime.parse(b['fecha_operativa']);
        return fechaB.compareTo(fechaA);
      });
      
      // Inyectamos tanto los datos de osmosis como la lista de umbrales
      _dataSource = _PozosDataSource(
        data: sortedData, 
        umbrales: listaUmbrales
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final BorderSide customBorder = BorderSide(
        color: ColorDefaults.darkPrimary.withOpacity(0.5), width: 2.5);

    return SizedBox(
      height: windowSize.height * 0.35,
      width: double.infinity,
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
    _buildColumn('fecha', 'Fecha', border),
    _buildColumn('MF01_in', 'MF01_in', border),
    _buildColumn('MF01_out', 'MF01_out', border),
    _buildColumn('MF01_pc', 'MF01 %', border),
    _buildColumn('MF02_in', 'MF02_in', border),
    _buildColumn('MF02_out', 'MF02_out', border),
    _buildColumn('MF02_pc', 'MF02 %', border),
    _buildColumn('MF04_in', 'MF04_in', border),
    _buildColumn('MF04_out', 'MF04_out', border),
    _buildColumn('MF04_pc', 'MF04 %', border),
    _buildColumn('MF05_in', 'MF05_in', border),
    _buildColumn('MF05_out', 'MF05_out', border),
    _buildColumn('MF05_pc', 'MF05 %', border),
    _buildColumn('MF06_in', 'MF06_in', border),
    _buildColumn('MF06_out', 'MF06_out', border),
    _buildColumn('MF06_pc', 'MF06 %', border),
  ];
}

GridColumn _buildColumn(String name, String label, BorderSide border) {
  return GridColumn(
      columnName: name,
      label: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: ColorDefaults.primaryBlue,
            border: Border(
                right: name == 'fecha' || name.contains('pc') ? border : BorderSide.none,
                left: name.contains('pc') ? border : BorderSide.none)),
        child: GlobalText(
          label,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: ColorDefaults.darkPrimary,
        ),
      ));
}

class _PozosDataSource extends DataGridSource {
  final List<Map<String, dynamic>> umbrales;

  _PozosDataSource({
    required List<dynamic> data, 
    required this.umbrales
  }) {
    _rows = data.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'fecha', value: item['fecha_operativa'].toString()),
        DataGridCell<num>(columnName: 'MF01_in', value: item['MF01_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF01_out', value: item['MF01_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF01_pc', value: item['MF01_pc'] ?? 0),
        DataGridCell<num>(columnName: 'MF02_in', value: item['MF02_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF02_out', value: item['MF02_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF02_pc', value: item['MF02_pc'] ?? 0),
        DataGridCell<num>(columnName: 'MF04_in', value: item['MF04_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF04_out', value: item['MF04_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF04_pc', value: item['MF04_pc'] ?? 0),
        DataGridCell<num>(columnName: 'MF05_in', value: item['MF05_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF05_out', value: item['MF05_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF05_pc', value: item['MF05_pc'] ?? 0),
        DataGridCell<num>(columnName: 'MF06_in', value: item['MF06_in'] ?? 0),
        DataGridCell<num>(columnName: 'MF06_out', value: item['MF06_out'] ?? 0),
        DataGridCell<num>(columnName: 'MF06_pc', value: item['MF06_pc'] ?? 0),
      ]);
    }).toList();
  }

  List<DataGridRow> _rows = [];
  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final BorderSide customBorder = BorderSide(
        color: ColorDefaults.darkPrimary.withOpacity(0.5), width: 1.5);

    return DataGridRowAdapter(
      color: ColorDefaults.whitePrimary,
      cells: row.getCells().map<Widget>((cell) {
        final bool isPC = cell.columnName.contains('pc');
        final bool isFecha = cell.columnName == 'fecha';

        // LÓGICA DE ALERTA (FONDO DE CELDA)
        // Por defecto, color según diseño original
        Color cellBackgroundColor = isPC ? ColorDefaults.secundaryBlue : Colors.transparent;
        Color cellTextColor = ColorDefaults.darkPrimary;

        if (isPC) {
          // Obtenemos el prefijo (ej. "MF01") de la columna "MF01_pc"
          String equipo = cell.columnName.split('_')[0];
          
          // Buscamos el umbral en la lista inyectada
          final umbralFila = umbrales.firstWhere(
            (u) => equipo.contains(u['argumento']),
            orElse: () => {},
          );

          if (umbralFila.isNotEmpty && umbralFila['umbral'] != null) {
            double limiteMax = (umbralFila['umbral'] as num).toDouble();
            double valorCelda = (cell.value as num).toDouble();
            
            // SI SUPERA EL LÍMITE: Pintamos TODA la celda de rojo
            if (valorCelda < limiteMax) {
              cellBackgroundColor = Colors.redAccent; // Rojo para el fondo
              cellTextColor = Colors.white; // Texto blanco para que resalte
            }
          }
        }

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: cellBackgroundColor, // Aplicamos el color de fondo dinámico
            border: Border(
              right: isFecha || isPC ? customBorder : BorderSide.none,
              left: isPC ? customBorder : BorderSide.none,
            ),
          ),
          child: GlobalText(
            isPC ? '${cell.value.toString()} %' : cell.value.toString(),
            fontSize: 12,
            color: cellTextColor, // Aplicamos color de texto (blanco en alerta, oscuro normal)
            fontWeight: isPC ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}