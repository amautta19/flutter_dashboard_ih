import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/supabase_services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  late _ConsumoDataSource _dataSource;
  List<dynamic> _allData = []; // Todos los datos de Supabase
  List<dynamic> _rawData = []; // Datos filtrados para la gráfica
  bool isLoading = true;

  // --- VARIABLES DE FILTRO ---
  String _mesSeleccionado = 'Todos';
  final List<String> _meses = [
    'Todos', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _services.getData(); 
      
      // Ordenamos Ascendente (Antiguo -> Nuevo) para la lógica base
      data.sort((a, b) {
        DateTime fechaA = DateTime.parse(a['fecha_operativa'].toString());
        DateTime fechaB = DateTime.parse(b['fecha_operativa'].toString());
        return fechaA.compareTo(fechaB); 
      });

      setState(() {
        _allData = data; 
        _rawData = data; 
        _dataSource = _ConsumoDataSource(data: List.from(data.reversed));
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  // --- FUNCIÓN DE FILTRADO ---
  void _filtrarPorMes(String? mes) {
    if (mes == null) return;

    List<dynamic> filtrados;
    if (mes == 'Todos') {
      filtrados = _allData;
    } else {
      int numeroMes = _meses.indexOf(mes); // Enero = 1, Marzo = 3...
      filtrados = _allData.where((item) {
        DateTime fecha = DateTime.parse(item['fecha_operativa'].toString());
        return fecha.month == numeroMes;
      }).toList();
    }

    setState(() {
      _mesSeleccionado = mes;
      _rawData = filtrados;
      _dataSource = _ConsumoDataSource(data: List.from(filtrados.reversed));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Industrial - Arca Continental'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Column(
                    children: [
                      // --- UI DE FILTRO ---
                      Card(
                        color: Colors.white.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month, color: Colors.blueAccent),
                              const SizedBox(width: 15),
                              const Text("Seleccionar Mes:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 20),
                              DropdownButton<String>(
                                value: _mesSeleccionado,
                                underline: Container(height: 2, color: Colors.blueAccent),
                                items: _meses.map((String mes) {
                                  return DropdownMenuItem<String>(value: mes, child: Text(mes));
                                }).toList(),
                                onChanged: (value) => _filtrarPorMes(value),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text("Historial de Consumo (Tabla)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      // --- TABLA ---
                      SizedBox(
                        height: 500,
                        child: SfDataGrid(
                          source: _dataSource,
                          columnWidthMode: ColumnWidthMode.fill,
                          headerRowHeight: 50,
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
                      ),

                      const SizedBox(height: 50),
                      const Divider(color: Colors.blueAccent, thickness: 2),
                      const SizedBox(height: 30),

                      // --- GRÁFICA ---
                      const Text("Análisis de Consumo CIP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        height: 450,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                        child: SfCartesianChart(
                          tooltipBehavior: TooltipBehavior(enable: true),
                          zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
                          primaryXAxis: CategoryAxis(
                            labelRotation: 45,
                            autoScrollingDelta: 14, 
                            autoScrollingMode: AutoScrollingMode.end, 
                          ),
                          primaryYAxis: const NumericAxis(
                            plotBands: <PlotBand>[
                              PlotBand(
                                isVisible: true, start: 300, end: 300, borderWidth: 3, 
                                borderColor: Colors.redAccent, dashArray: <double>[6, 6],
                                text: 'ALERTA 300', textStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          series: <CartesianSeries<dynamic, String>>[
                            ColumnSeries<dynamic, String>(
                              dataSource: _rawData,
                              xValueMapper: (data, _) => data['fecha_operativa'].toString(),
                              yValueMapper: (data, _) => data['CIP'] ?? 0,
                              pointColorMapper: (data, _) => (data['CIP'] ?? 0) > 300 ? Colors.redAccent : Colors.blueAccent,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                              dataLabelSettings: const DataLabelSettings(isVisible: true),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  GridColumn _buildColumn(String name, String label, {bool isTotal = false}) {
    return GridColumn(
      columnName: name,
      label: Container(
        alignment: Alignment.center,
        color: isTotal ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}

class _ConsumoDataSource extends DataGridSource {
  _ConsumoDataSource({required List<dynamic> data}) {
    _rows = data.map<DataGridRow>((item) {
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
          child: Text(cell.value.toString(), style: TextStyle(fontSize: 12, color: isTotal ? Colors.blueAccent : Colors.white, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        );
      }).toList(),
    );
  }
}