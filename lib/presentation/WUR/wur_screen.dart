import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';

class WurScreen extends StatefulWidget {
  const WurScreen({super.key});

  @override
  State<WurScreen> createState() => _WurScreenState();
}

class _WurScreenState extends State<WurScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarDesign(
        title: 'WUR - PLANTA PUCUSANA', 
        colorBar: Colors.redAccent, 
        table: 'wur_hora'
      ),
      drawer: NavbarDisgn(),
      body: Center(
        child: Text('WUR PLANTA PUCUSANA'),
      ),
    );
  }
}