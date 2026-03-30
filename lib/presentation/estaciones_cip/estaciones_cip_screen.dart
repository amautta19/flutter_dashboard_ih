import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';

class EstacionesCipScreen extends StatefulWidget {
  const EstacionesCipScreen({super.key});

  @override
  State<EstacionesCipScreen> createState() => _EstacionesCipScreenState();
}

class _EstacionesCipScreenState extends State<EstacionesCipScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarDesign(
        title: 'Consumo Agua Estaciones CIP - Planta Pucusana', 
        colorBar: Colors.greenAccent, 
        table: 'estaciones_cip'
      ),
      drawer: NavbarDisgn(),
      body: Column(
        children: [
          Text('Estaciones CIP')
        ],
      ),
    );
  }
}