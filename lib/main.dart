import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/supabase_services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Asumo que aquí tienes tu servicio de Supabase
// import 'package:flutter_dashboard_ih/supabase_services.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qskfiowkylkfqckfokqy.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFza2Zpb3dreWxrZnFja2Zva3F5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MTc0MTMsImV4cCI6MjA4ODI5MzQxM30.ZaMpdUWEY0eAydVnZeuA0ns4uSwXotx21FVhfFT4yYY', 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Mantenemos tu estilo Dark
      home: const WindowsTableScreen(),
    );
  }
}

class WindowsTableScreen extends StatefulWidget {
  const WindowsTableScreen({super.key});
  @override
  State<WindowsTableScreen> createState() => _WindowsTableScreenState();
}

class _WindowsTableScreenState extends State<WindowsTableScreen> {
  final SupabaseServices _services = SupabaseServices();
  late _ConsumoDataSource _dataSource;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Supongamos que esto devuelve tu List<Map<String, dynamic>>
      final data = await _services.getData(); 
      // final data = []; // Simulación para el ejemplo

      setState(() {
        _dataSource = _ConsumoDataSource(data: data);
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consumo de Agua - Industrial')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SfDataGrid(
              source: _dataSource,
              columnWidthMode: ColumnWidthMode.fill,
              allowColumnsResizing: true,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columns: [
                _buildColumn('fecha', 'Fecha'),
                _buildColumn('cip', 'CIP'),
                _buildColumn('desaireadorA', 'Des. A'),
                _buildColumn('desaireadorB', 'Des. B'),
                _buildColumn('desaireadorC', 'Des. C'),
                _buildColumn('fuerza', 'Fuerza'),
                _buildColumn('lavadoras', 'Lavadoras'),
                _buildColumn('lineasPET', 'Líneas PET'),
                _buildColumn('multimix', 'Multimix'),
                _buildColumn('potable', 'Potable'),
                _buildColumn('quasy', 'Quasy'),
                _buildColumn('servicios', 'Servicios'),
                _buildColumn('contisolv', 'Contisolv'),
                _buildColumn('total', 'TOTAL', isTotal: true),
              ],
            ),
    );
  }

  GridColumn _buildColumn(String name, String label, {bool isTotal = false}) {
    return GridColumn(
      columnName: name,
      label: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: isTotal ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// El motor de la tabla
class _ConsumoDataSource extends DataGridSource {
  _ConsumoDataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
      // Tu lógica de suma que ya tenías
      final total = (item['CIP'] ?? 0) + (item['DesaireadorA'] ?? 0) + (item['DesaireadorB'] ?? 0) +
                    (item['DesaireadorC'] ?? 0) + (item['Fuerza'] ?? 0) + (item['Lavadoras'] ?? 0) +
                    (item['LineasPET'] ?? 0) + (item['Multimix'] ?? 0) + (item['Potable'] ?? 0) +
                    (item['Quasy'] ?? 0) + (item['Servicios'] ?? 0) + (item['Contisiolv'] ?? 0);

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

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        final bool isTotal = cell.columnName == 'total';
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          color: isTotal ? Colors.blueAccent.withOpacity(0.1) : null,
          child: Text(
            cell.value.toString(),
            style: TextStyle(
              color: isTotal ? Colors.blueAccent : Colors.white,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}