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
  List<dynamic> _allData = []; 
  List<dynamic> _rawData = []; 
  bool isLoading = true;

  // --- FILTROS ---
  String _mesSeleccionado = 'Todos';
  final List<String> _meses = ['Todos', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

  String _campoGrafica = 'CIP'; 
  final Map<String, String> _opcionesGrafica = {
    'CIP': 'CIP',
    'DesaireadorA': 'Des. A',
    'DesaireadorB': 'Des. B',
    'DesaireadorC': 'Des. C',
    'Fuerza': 'Fuerza',
    'Lavadoras': 'Lavadoras',
    'LineasPET': 'Líneas PET',
    'Multimix': 'Multimix',
    'Potable': 'Potable',
    'Quasy': 'Quasy',
    'Servicios': 'Servicios',
    'Contisiolv': 'Contisolv',
    'total': 'Total Consumo',
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- FUNCIÓN PARA CALCULAR EL PROMEDIO DINÁMICO ---
  double _calcularPromedio() {
    if (_rawData.isEmpty) return 0;
    
    double suma = 0;
    for (var item in _rawData) {
      if (_campoGrafica == 'total') {
        suma += (item['CIP'] ?? 0) + (item['DesaireadorA'] ?? 0) + (item['DesaireadorB'] ?? 0) + 
                (item['DesaireadorC'] ?? 0) + (item['Fuerza'] ?? 0) + (item['Lavadoras'] ?? 0) + 
                (item['LineasPET'] ?? 0) + (item['Multimix'] ?? 0) + (item['Potable'] ?? 0) + 
                (item['Quasy'] ?? 0) + (item['Servicios'] ?? 0) + (item['Contisiolv'] ?? 0);
      } else {
        suma += (item[_campoGrafica] ?? 0);
      }
    }
    return suma / _rawData.length;
  }

  Future<void> _fetchData() async {
    try {
      final data = await _services.getData(); 
      data.sort((a, b) => DateTime.parse(a['fecha_operativa'].toString()).compareTo(DateTime.parse(b['fecha_operativa'].toString())));

      setState(() {
        _allData = data; 
        _rawData = data; 
        _dataSource = _ConsumoDataSource(data: List.from(data.reversed));
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filtrarPorMes(String? mes) {
    if (mes == null) return;
    List<dynamic> filtrados = mes == 'Todos' 
      ? _allData 
      : _allData.where((item) => DateTime.parse(item['fecha_operativa'].toString()).month == _meses.indexOf(mes)).toList();

    setState(() {
      _mesSeleccionado = mes;
      _rawData = filtrados;
      _dataSource = _ConsumoDataSource(data: List.from(filtrados.reversed));
    });
  }

  @override
  Widget build(BuildContext context) {
    double promedioActual = _calcularPromedio();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Arca Continental - Análisis Real-Time'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // --- PANEL DE FILTROS ---
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFilterCard("Mes", DropdownButton<String>(
                        value: _mesSeleccionado,
                        items: _meses.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: _filtrarPorMes,
                      )),
                      _buildFilterCard("Sensor", DropdownButton<String>(
                        value: _campoGrafica,
                        items: _opcionesGrafica.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                        onChanged: (val) => setState(() => _campoGrafica = val!),
                      )),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- TABLA ---
                  SizedBox(height: 400, child: SfDataGrid(source: _dataSource, columnWidthMode: ColumnWidthMode.fill, columns: _getColumns())),

                  const SizedBox(height: 40),
                  const Divider(color: Colors.blueAccent, thickness: 2),

                  // --- GRÁFICA CON PROMEDIO DINÁMICO ---
                  Text(
                    "Tendencia de ${_opcionesGrafica[_campoGrafica]} (Promedio: ${promedioActual.toStringAsFixed(2)})", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 450,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: SfCartesianChart(
                      tooltipBehavior: TooltipBehavior(enable: true),
                      zoomPanBehavior: ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x),
                      primaryXAxis: CategoryAxis(labelRotation: 45, autoScrollingDelta: 14, autoScrollingMode: AutoScrollingMode.end),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: _opcionesGrafica[_campoGrafica]),
                        plotBands: <PlotBand>[
                          PlotBand(
                            isVisible: true,
                            start: promedioActual,
                            end: promedioActual,
                            borderWidth: 3,
                            borderColor: Colors.orangeAccent, // Cambié a naranja para diferenciar de alerta fija
                            dashArray: <double>[6, 6],
                            text: 'PROMEDIO: ${promedioActual.toStringAsFixed(2)}',
                            textStyle: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                            horizontalTextAlignment: TextAnchor.end,
                          )
                        ],
                      ),
                      series: <CartesianSeries<dynamic, String>>[
                        ColumnSeries<dynamic, String>(
                          name: _opcionesGrafica[_campoGrafica],
                          dataSource: _rawData,
                          xValueMapper: (data, _) => data['fecha_operativa'].toString(),
                          yValueMapper: (data, _) {
                            if (_campoGrafica == 'total') {
                               return (data['CIP'] ?? 0) + (data['DesaireadorA'] ?? 0) + (data['DesaireadorB'] ?? 0) + (data['DesaireadorC'] ?? 0) + (data['Fuerza'] ?? 0) + (data['Lavadoras'] ?? 0) + (data['LineasPET'] ?? 0) + (data['Multimix'] ?? 0) + (data['Potable'] ?? 0) + (data['Quasy'] ?? 0) + (data['Servicios'] ?? 0) + (data['Contisiolv'] ?? 0);
                            }
                            return data[_campoGrafica] ?? 0;
                          },
                          // Pintamos de rojo solo lo que esté POR ENCIMA del promedio dinámico
                          pointColorMapper: (data, _) {
                            num valor;
                            if (_campoGrafica == 'total') {
                              valor = (data['CIP'] ?? 0) + (data['DesaireadorA'] ?? 0) + (data['DesaireadorB'] ?? 0) + (data['DesaireadorC'] ?? 0) + (data['Fuerza'] ?? 0) + (data['Lavadoras'] ?? 0) + (data['LineasPET'] ?? 0) + (data['Multimix'] ?? 0) + (data['Potable'] ?? 0) + (data['Quasy'] ?? 0) + (data['Servicios'] ?? 0) + (data['Contisiolv'] ?? 0);
                            } else {
                              valor = data[_campoGrafica] ?? 0;
                            }
                            return valor > promedioActual ? Colors.redAccent : Colors.blueAccent;
                          },
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
    );
  }

  Widget _buildFilterCard(String title, Widget dropdown) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), child: Row(children: [Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)), dropdown])),
    );
  }

  List<GridColumn> _getColumns() {
    return [
      _buildColumn('fecha', 'Fecha'), _buildColumn('cip', 'CIP'), _buildColumn('desaireadorA', 'Des. A'), _buildColumn('desaireadorB', 'Des. B'),
      _buildColumn('desaireadorC', 'Des. C'), _buildColumn('fuerza', 'Fuerza'), _buildColumn('lavadoras', 'Lavadoras'), _buildColumn('lineasPET', 'Líneas PET'),
      _buildColumn('multimix', 'Multimix'), _buildColumn('potable', 'Potable'), _buildColumn('quasy', 'Quasy'), _buildColumn('servicios', 'Servicios'),
      _buildColumn('contisolv', 'Contisolv'), _buildColumn('total', 'TOTAL', isTotal: true),
    ];
  }

  GridColumn _buildColumn(String name, String label, {bool isTotal = false}) {
    return GridColumn(columnName: name, label: Container(alignment: Alignment.center, color: isTotal ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))));
  }
}

// DataSource se mantiene igual para manejar la tabla
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
  @override DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: row.getCells().map<Widget>((cell) {
      final bool isTotal = cell.columnName == 'total';
      return Container(alignment: Alignment.center, padding: const EdgeInsets.all(8), color: isTotal ? Colors.blueAccent.withOpacity(0.1) : null, child: Text(cell.value.toString(), style: TextStyle(fontSize: 12, color: isTotal ? Colors.blueAccent : Colors.white, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)));
    }).toList());
  }
}