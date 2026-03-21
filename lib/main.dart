import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/supabase_services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tus credenciales configuradas
  await Supabase.initialize(
    url: 'https://qskfiowkylkfqckfokqy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFza2Zpb3dreWxrZnFja2Zva3F5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MTc0MTMsImV4cCI6MjA4ODI5MzQxM30.ZaMpdUWEY0eAydVnZeuA0ns4uSwXotx21FVhfFT4yYY',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
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
  List<PlutoRow> rows = [];
  bool isLoading = true;

  // Definimos las columnas (asegúrate que el 'field' sea igual al nombre en Supabase)
  final List<PlutoColumn> columns = [
    PlutoColumn(title: 'Fecha', field: 'fecha', type: PlutoColumnType.text(),),
    PlutoColumn(title: 'CIP', field: 'cip', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Desaireador A', field: 'desaireadorA', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Desaireador B', field: 'desaireadorB', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Desaireador C', field: 'desaireadorC', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Fuerza', field: 'fuerza', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Lavadoras', field: 'lavadoras', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Lineas PET', field: 'lineasPET', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Multimix', field: 'multimix', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Potable', field: 'potable', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Quasy', field: 'quasy', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Servicios', field: 'servicios', type: PlutoColumnType.number()),
    PlutoColumn(title: 'Contisolv', field: 'contisolv', type: PlutoColumnType.number()),
  ].map((column){
      column.enableContextMenu = false;
      column.enableColumnDrag = false;
      column.enableDropToResize = false;
      return column;
  }).toList();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _services.getData();

      // 2. Convertimos los mapas de Supabase a filas de PlutoGrid
      setState(() {
        rows = data.map((item) => PlutoRow(
          cells: {
            'fecha': PlutoCell(value: item['fecha_operativa'].toString()),
            'cip': PlutoCell(value: item['CIP'] ?? 0),
            'desaireadorA': PlutoCell(value: item['DesaireadorA'] ?? 0),
            'desaireadorB': PlutoCell(value: item['DesaireadorB'] ?? 0),
            'desaireadorC': PlutoCell(value: item['DesaireadorC'] ?? 0),
            'fuerza': PlutoCell(value: item['Fuerza'] ?? 0),
            'lavadoras': PlutoCell(value: item['Lavadoras'] ?? 0),
            'lineasPET': PlutoCell(value: item['LineasPET'] ?? 0),
            'multimix': PlutoCell(value: item['Multimix'] ?? 0),
            'potable': PlutoCell(value: item['Potable'] ?? 0),
            'quasy': PlutoCell(value: item['Quasy'] ?? 0),
            'servicios': PlutoCell(value: item['Servicios'] ?? 0),
            'contisolv': PlutoCell(value: item['Contisiolv'] ?? 0),
          },
        )).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consumo de Agua')),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) // Mientras carga
        : PlutoGrid(
            columns: columns,
            rows: rows,
            configuration: PlutoGridConfiguration(
              columnSize: PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.equal
              ),
              style: PlutoGridStyleConfig(
                columnTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
                cellTextStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.black
                ),
                gridBorderColor: Colors.transparent,
              ),
            ),
          ),
    );
  }
}