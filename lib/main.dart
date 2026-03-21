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
  List<dynamic> _rawData = []; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _services.getData(); 
      setState(() {
        _rawData = data; 
        _dataSource = _ConsumoDataSource(data: data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumo de Agua - Dashboard Industrial'),
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
                      const Text(
                        "Historial de Consumo Operativo",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // --- TABLA DE 500PX ---
                      SizedBox(
                        height: 500,
                        child: SfDataGrid(
                          source: _dataSource,
                          columnWidthMode: ColumnWidthMode.fill,
                          headerRowHeight: 50,
                          allowColumnsResizing: true,
                          gridLinesVisibility: GridLinesVisibility.both,
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          isScrollbarAlwaysShown: true,
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

                      // --- GRÁFICA DE BARRAS CIP CON LÍMITE ---
                      const Text(
                        "Análisis de Consumo CIP (Límite: 500)",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 450,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SfCartesianChart(
                          tooltipBehavior: TooltipBehavior(enable: true),
                          primaryXAxis: const CategoryAxis(
                            title: AxisTitle(text: 'Fecha'),
                            labelRotation: 45,
                          ),
                          primaryYAxis: const NumericAxis(
                            title: AxisTitle(text: 'm³ Consumidos'),
                            // LÍNEA DE REFERENCIA 500
                            plotBands: <PlotBand>[
                              PlotBand(
                                isVisible: true,
                                start: 300,
                                end: 300,
                                borderWidth: 3,
                                borderColor: Colors.redAccent,
                                dashArray: <double>[6, 6],
                                text: 'ALERTA 500',
                                textStyle: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                horizontalTextAlignment: TextAnchor.end,
                              )
                            ],
                          ),
                          series: <CartesianSeries<dynamic, String>>[
                            ColumnSeries<dynamic, String>(
                              name: 'Consumo CIP',
                              dataSource: _rawData,
                              xValueMapper: (data, _) => data['fecha_operativa'].toString(),
                              yValueMapper: (data, _) => data['CIP'] ?? 0,
                              // Lógica de color: Rojo si pasa de 500, Azul si no.
                              pointColorMapper: (data, _) {
                                num valor = data['CIP'] ?? 0;
                                return valor > 300 ? Colors.redAccent : Colors.blueAccent;
                              },
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(fontSize: 10, color: Colors.white),
                              ),
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
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: isTotal ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

// MOTOR DE LA TABLA
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
          child: Text(
            cell.value.toString(),
            style: TextStyle(
              fontSize: 12,
              color: isTotal ? Colors.blueAccent : Colors.white,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}