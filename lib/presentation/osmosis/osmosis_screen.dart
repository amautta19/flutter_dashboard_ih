import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/osmosis/table_osmosis.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:provider/provider.dart';
class OsmosisScreen extends StatefulWidget {
  const OsmosisScreen({super.key});

  @override
  State<OsmosisScreen> createState() => _OsmosisScreenState();
}

class _OsmosisScreenState extends State<OsmosisScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<FilterMonthProvider>().getMonth;
    final windowsSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppbarDesign(
        title: 'Consumo Agua Ósmosis - Planta Pucusana', 
        colorBar: Colors.purpleAccent, 
        table: 'osmosis'
      ),
      drawer: NavbarDisgn(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              StreamBuilder<List<dynamic>>(
                stream: SupabaseServices().getData('osmosis_diario'), 
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
                      GlobalText('Registro de Consumo Diario Ósmosis', fontSize: 16, fontWeight: FontWeight.bold, color: ColorDefaults.secundaryBlue,),
                      Row(
                        children: [
                          TablaOsmosis(osmosisData: filteredData)
                        ],
                      )
                    ],
                  );
                }
              )
            ],
          ),
        ),
      )
    );
  }
}