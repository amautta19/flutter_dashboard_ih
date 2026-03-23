import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/graph_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/tables_manifold.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/supabase_services.dart';
import 'package:provider/provider.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final SupabaseServices _services = SupabaseServices();
  List<dynamic> _allData = [];
  List<dynamic> _rawData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async{
    try{
      final data = await _services.getData();
      data.sort((a, b) => DateTime.parse(a['fecha_operativa'].toString()).compareTo(DateTime.parse(b['fecha_operativa'].toString())));
      setState(() {
        _allData = data;
        _rawData = data;
        isLoading = false;
      });
    } catch (e){
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerMotn = Provider.of<FilterMonthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: GlobalText('Consumo de agua de Manifold'),
        centerTitle: true,
      ),
      body:isLoading
          ? Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue,))
          : SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text(providerMotn.getMonth),
                FilterMonth(),
                const SizedBox(height: 10),
                TableManifoldWidget(allData: _allData,),
                const SizedBox(height: 20,),
                GraphManifoldWidget(allData: _allData,)
              ],
            ),
          )
    );
  }
}