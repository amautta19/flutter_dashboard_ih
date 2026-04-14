import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/fiiltros_pulidores/table_filtros_plulidores.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/bar_graph_diary.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/bar_graph_hours.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/distribution_chart.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_day.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_elements.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:provider/provider.dart';

class FiltrosPulidoresScreen extends StatefulWidget {
  const FiltrosPulidoresScreen({super.key});

  @override
  State<FiltrosPulidoresScreen> createState() => _FiltrosPulidoresScreenState();
}

class _FiltrosPulidoresScreenState extends State<FiltrosPulidoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<FilterElementProvider>().updateColumn('AF01'); 
    });
  }
  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<FilterMonthProvider>().getMonth;
    final windowSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppbarDesign(
        title: 'Consumo Agua Filtros Pulidores - Planta Pucusana', 
        colorBar: Colors.limeAccent, 
        table: 'filtros_pulidores',
        filterByDay: true,
      ),
      drawer: NavbarDisgn(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              StreamBuilder<List<dynamic>>(
                stream: SupabaseServices().getData('filtros_pulidores_diario'),
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
                    } catch (e) {return false;}
                  }).toList();
                  if(filteredData.isEmpty){
                    return const Center(child: GlobalText('No hay datos para este mes seleccionado', fontSize: 24,));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlobalText('Registro de Consumo Diario Filtros Pulidores', fontSize: 16, fontWeight: FontWeight.bold, color: ColorDefaults.secundaryBlue,),
                      Row(
                        children: [
                          TablaFiltrosPulidores(cipData: filteredData),
                          const Spacer(),
                          DistributionBarChart(allData: filteredData, columns: ['AF01', 'AF02', 'AF03', 'AF04', 'AF05', 'AF06', 'KF09', 'KF10'])
                        ],
                      ),
                      const SizedBox(height: 30,),
                      Column(
                        children: [
                          Row(
                            children: [
                              FilterElementWidget(columns: ['AF01', 'AF02', 'AF03', 'AF04', 'AF05', 'AF06', 'KF09', 'KF10']),
                              const Spacer(),
                              FilterDayWidget(),
                              const SizedBox(width: 100,)
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              BarGraphDiary(allData: filteredData),
                              const Spacer(),
                              Consumer<FilterDayProvider>(
                                builder: (context, dayProvider, child){
                                  return Column(
                                    children: [
                                      StreamBuilder(
                                        stream: SupabaseServices().getDataByDayOperative('filtros_pulidores', dayProvider.getDate), 
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
                                          return BarGraphHours(allData: snapshot.data!);
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