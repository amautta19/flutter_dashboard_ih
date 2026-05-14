import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TableWurSemanal extends StatefulWidget {
  final List<dynamic> allData; 
  const TableWurSemanal({super.key, required this.allData});

  @override
  State<TableWurSemanal> createState() => _TableWurSemanalState();
}

class _TableWurSemanalState extends State<TableWurSemanal> {
  // Inicializamos con un DataSource vacío para evitar LateInitializationError
  _ConsumoDataSource _dataSource = _ConsumoDataSource(data: [], umbralReferencia: 0.0);
  
  @override
  void initState() {
    super.initState();
    // Esperamos al primer frame para leer el Provider y cargar datos
    WidgetsBinding.instance.addPostFrameCallback((_) => _actualizarDataSource());
  }

  @override
  void didUpdateWidget(TableWurSemanal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allData != widget.allData) {
      _actualizarDataSource();
    }
  }

  void _actualizarDataSource() {
    if (!mounted) return;

    // Obtenemos el umbral de WUR del Provider
    final umbralesProvider = context.read<UmbralesProvider>();
    final umbralMap = umbralesProvider.tablaUmbrales.firstWhere(
      (elemento) => elemento['argumento'] == 'wur',
      orElse: () => {'umbral': 1.52}, // Valor de respaldo
    );
    
    double valorWurRef = (umbralMap['umbral'] as num).toDouble();

    setState(() {
      List<dynamic> sortedData = List.from(widget.allData);
      
      // Ordenamiento por fecha descendente
      if (sortedData.isNotEmpty) {
        sortedData.sort((a, b) {
          DateTime fechaA = DateTime.parse(a['semana_inicio'] ?? DateTime.now().toString());
          DateTime fechaB = DateTime.parse(b['semana_inicio'] ?? DateTime.now().toString());
          return fechaB.compareTo(fechaA);
        });
      }

      // Re-instanciamos el DataSource con los datos y el umbral real
      _dataSource = _ConsumoDataSource(
        data: sortedData,
        umbralReferencia: valorWurRef,
      );
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
      height: windowSize.height * 0.3,
      width: windowSize.width * 0.20,
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
    _buildColumn('fecha_inicio', 'Día Inicio', border), 
    _buildColumn('wur_semanal', 'WUR', border), 
  ];
}

GridColumn _buildColumn(String name, String label, BorderSide border) {
  return GridColumn(
    columnName: name, 
    label: Container(
      alignment: Alignment.center, 
      decoration: BoxDecoration(color: ColorDefaults.primaryBlue),
      child: GlobalText(
        label, 
        fontWeight: FontWeight.bold, 
        fontSize: 14, 
        color: ColorDefaults.darkPrimary
      ),
    )
  );
}

class _ConsumoDataSource extends DataGridSource {
  final double umbralReferencia;

  _ConsumoDataSource({required List<dynamic> data, required this.umbralReferencia}) {
    _rows = data.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'semana', 
          value: item['semana_label']?.toString() ?? 'N/A'
        ),
        DataGridCell<String>(
          columnName: 'fecha_inicio', 
          value: item['semana_inicio']?.toString() ?? 'N/A'
        ),
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
        
        Color cellBackgroundColor = Colors.transparent;
        Color textColor = ColorDefaults.darkPrimary;

        if (isWur) {
          double valorCelda = (cell.value as num).toDouble();
          // Lógica de semáforo industrial: Rojo si supera el umbral, Verde si es eficiente
          cellBackgroundColor = valorCelda > umbralReferencia 
              ? Colors.redAccent.withOpacity(0.9) 
              : Colors.greenAccent.withOpacity(0.9);
          textColor = Colors.black;
        }

        return Container(
          alignment: Alignment.center, 
          padding: const EdgeInsets.symmetric(horizontal: 8), 
          decoration: BoxDecoration(
            color: cellBackgroundColor,
            border: Border(
              left: isWur ? customBorder : BorderSide.none,
            ),
          ),
          child: GlobalText(
            cell.value.toString(), 
            fontSize: 12, 
            color: textColor,
            fontWeight: isWur ? FontWeight.bold : FontWeight.normal
          ),
        );
      }).toList(),
    );
  }
}