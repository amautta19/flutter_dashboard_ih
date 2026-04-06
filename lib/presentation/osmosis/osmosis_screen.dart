import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';
class OsmosisScreen extends StatefulWidget {
  const OsmosisScreen({super.key});

  @override
  State<OsmosisScreen> createState() => _OsmosisScreenState();
}

class _OsmosisScreenState extends State<OsmosisScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarDesign(
        title: 'Consumo Agua Ósmosis - Planta Pucusana', 
        colorBar: Colors.purpleAccent, 
        table: 'osmosis'
      ),
      drawer: NavbarDisgn(),
      body: Column(
        children: [
          Text('Osmosis')
        ],
      ),
    );
  }
}