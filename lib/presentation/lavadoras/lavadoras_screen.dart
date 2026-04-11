import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';

class LavadorasScreen extends StatefulWidget {
  const LavadorasScreen({super.key});

  @override
  State<LavadorasScreen> createState() => _LavadorasScreenState();
}

class _LavadorasScreenState extends State<LavadorasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarDesign(
        title: 'Consumo Agua Lavadoras - Pucusana', 
        colorBar: Colors.redAccent, 
        table: 'tiempo_efectivo'
      ),
      drawer: NavbarDisgn(),
      body: Column(
        children: [
          Text('Lavadoras')
        ],
      ),
    );
  }
}