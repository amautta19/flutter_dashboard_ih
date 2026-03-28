import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_elements.dart';
import 'package:flutter_dashboard_ih/presentation/manifold/distribution_chart.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_day.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/presentation/manifold/tables_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/manifold/graph_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/presentation/manifold/line_chart.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<FilterElementProvider>().updateColumn('CIP'); 
  });
  }
  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    // Escuchamos el mes. Si cambia el mes, se refresca todo (esto es correcto).
    final selectedMonth = context.watch<FilterMonthProvider>().getMonth;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorDefaults.primaryBlue,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GlobalText(
                'Consumo Planta Pucusana', 
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: ColorDefaults.darkPrimary,
              ),
              const Spacer(),
              StreamBuilder(
                stream: SupabaseServices().getLastUpdate(), 
                builder: (context, snapshot){
                  if(snapshot.hasData && snapshot.data != null){
                    DateTime dt = DateTime.parse(snapshot.data!['_time_lima']);
                    String formattedDate = DateFormat('yyy/MM/dd HH:mm').format(dt);
                    return GlobalText(
                      'Actualizado: $formattedDate',
                      fontSize: 20, color: ColorDefaults.whitePrimary, fontWeight: FontWeight.bold,
                    );
                  }
                  return GlobalText('Sin actualización registrada');
                }
              )
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10,),
              FilterMonthWidget(),
              const SizedBox(width: 200,)
            ],
          ),
        ],
      ),
      drawer: NavbarDisgn(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              // --- FUTURE BUILDER PRINCIPAL (DEPENDE DEL MES) ---
              StreamBuilder<List<dynamic>>(
                stream: SupabaseServices().getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: GlobalText('Error al obtener los datos!', fontSize: 24, color: Colors.red,));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: GlobalText('Sin datos disponibles', fontSize: 24));
                  }

                  final filteredData = snapshot.data!.where((item) {
                    try {
                      final fecha = DateTime.parse(item['fecha_operativa']);
                      return fecha.month == selectedMonth;
                    } catch (e) { return false; }
                  }).toList();

                  if (filteredData.isEmpty) {
                    return const Center(child: GlobalText('No hay datos para este mes seleccionado', fontSize: 24,));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlobalText('Registro de Consumo Diario Manifold - Planta Pucusana', fontSize: 16, fontWeight: FontWeight.bold, color: ColorDefaults.secundaryBlue,),
                      const SizedBox(height: 5,),
                      Row(
                        children: [
                          TableManifoldWidget(allData: filteredData),
                          const Spacer(),
                          DistributionBarChart(allData: filteredData)
                        ],
                      ),
                      const SizedBox(height: 30,),
                      Column(
                        children: [
                          Row(
                            children: [
                              FilterPozo(columns: ['CIP', 'DesaireadorA', 'DesaireadorB', 'DesaireadorC', 'Fuerza', 'Lavadoras', 'LineasPET', 'Multimix', 'Potable', 'Quasy', 'Servicios', 'Contisiolv']),
                              const Spacer(),
                              FilterDayWidget(),
                              const SizedBox(width: 100,)
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              GraphManifoldWidget(allData: filteredData,),
                              const Spacer(),
                              Consumer<FilterDayProvider>(
                                builder: (context, dayProvider, child){
                                  return Column(
                                    children: [
                                      StreamBuilder(
                                        stream: SupabaseServices().getDataByDayOperative(dayProvider.getDate), 
                                        builder: (context, snapshot){
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return SizedBox(
                                              height: windowSize.height * 0.42,
                                              width: windowSize.width * 0.38,
                                              child: Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue,),),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return SizedBox(
                                             height: windowSize.height * 0.42,
                                              width: windowSize.width * 0.38,
                                              child: Center(child: GlobalText('Error al obtener los datos! ${snapshot.error}', fontSize: 24, color: Colors.red,),),
                                            );
                                          }
                                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                            // return Center(child: GlobalText('Sin datos disponibles entre ese rango de fechas', fontSize: 24));
                                            return SizedBox(
                                              height: windowSize.height * 0.42,
                                              width: windowSize.width * 0.38,
                                              child: Center(child: GlobalText('Sin datos disponibles para el día seleccionado', fontSize: 24,)),
                                            );
                                          }
                                          return LineTrendChart(allData: snapshot.data!);
                                        }
                                      )
                                    ],
                                  );
                                }
                              ),
                              // LineTrendChart(allData: snapshot.data!)
                            ],
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}