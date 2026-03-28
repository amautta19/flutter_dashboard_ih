import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/pozos_vista/graph_hour_pozos.dart';
import 'package:flutter_dashboard_ih/presentation/pozos_vista/graph_pozos.dart';
import 'package:flutter_dashboard_ih/presentation/pozos_vista/piechar_pozos.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_day.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_elements.dart';
import 'package:flutter_dashboard_ih/presentation/pozos_vista/table_pozos.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_disgn.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:provider/provider.dart';

class PozoScreen extends StatefulWidget {
  const PozoScreen({super.key});

  @override
  State<PozoScreen> createState() => _PozoScreenState();
}

class _PozoScreenState extends State<PozoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilterElement>().updateColumn('Pozo1'); 
    });
  }
  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<FilterMonthProvider>().selectedMonth;
    final windowSize =  MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              GlobalText(
                'Consumo Pozos - Planta Pucusana',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ColorDefaults.darkPrimary,
              ),
              const Spacer()
            ],
          ),
        ),
        actions: [
          FilterMonthWidget(),
          const SizedBox(width: 200,)
        ],
      ),
      drawer: NavbarDisgn(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              StreamBuilder<List<dynamic>>(
                stream: SupabaseServices().getData(), 
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: GlobalText('Error al obtener los datos!', fontSize: 24, color: Colors.red,));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: GlobalText('Sin datos disponibles', fontSize: 24));
                  }

                  final filteredData = snapshot.data!.where((item){
                    try{
                      final fecha = DateTime.parse(item['fecha_operativa']);
                      return fecha.month == selectedMonth;
                    } catch(e) {return false;}
                  }).toList();
                  if (filteredData.isEmpty){
                    return const Center(child: GlobalText('No hay datos para este mes seleccionado', fontSize: 24,));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlobalText('Registro de Consumo Diario Pozos',fontSize: 16,fontWeight: FontWeight.bold, color: ColorDefaults.secundaryBlue,),
                      Row(
                        children: [
                          TablePozos(pozosData: filteredData),
                          const Spacer(),
                          PozosPieChart(allData: filteredData)
                        ],
                      ),
                      const SizedBox(height: 30,),
                      Column(
                        children: [
                          Row(
                            children: [
                              FilterPozo(columns: ['Pozo1', 'Pozo3']),
                              const Spacer(),
                              FilterDayWidget(),
                              const SizedBox(width: 100,)
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              GraphPozos(pozosData: filteredData),
                              const Spacer(),
                              Consumer<FilterDayProvider>(
                                builder: (context, dayProvider, child){
                                  return Column(
                                    children: [
                                      StreamBuilder(
                                        stream: SupabaseServices().getDataByDayOperative(dayProvider.selectedDate), 
                                        builder:(context, snapshot){
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
                                          return GraphHourPozos(pozosData: snapshot.data!);
                                        } 
                                      )
                                    ],
                                  );
                                }
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  );
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}