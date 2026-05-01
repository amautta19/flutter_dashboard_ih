import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/WUR/table_wur.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/bar_graph_diary.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:provider/provider.dart';

class WurScreen extends StatefulWidget {
  const WurScreen({super.key});

  @override
  State<WurScreen> createState() => _WurScreenState();
}

class _WurScreenState extends State<WurScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<FilterElementProvider>().updateColumn('wur');
    });
  }
  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<FilterMonthProvider>().getMonth;
    return Scaffold(
      appBar: AppbarDesign(
        title: 'WUR - PLANTA PUCUSANA', 
        colorBar: Colors.redAccent, 
        table: 'wur_hora'
      ),
      drawer: NavbarDisgn(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              // --- FUTURE BUILDER PRINCIPAL (DEPENDE DEL MES) ---
              StreamBuilder<List<dynamic>>(
                stream: SupabaseServices().getData('wur_diario'),
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
                      GlobalText('Registro de WUR - Planta Pucusana', fontSize: 16, fontWeight: FontWeight.bold, color: ColorDefaults.secundaryBlue,),
                      BarGraphDiary(
                        allData: filteredData,
                        titleM: 'WUR',
                        unidadM: '',
                        widthGraph: 1,
                        maxLabel: 20,),
                      const SizedBox(height: 5,),
                      Row(
                        children: [
                          TableWur(allData: filteredData),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 30,),
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