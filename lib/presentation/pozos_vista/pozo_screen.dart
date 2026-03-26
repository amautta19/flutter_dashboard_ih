import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_disgn.dart';

class PozoScreen extends StatelessWidget {
  const PozoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consumo Pozos'),
      ),
      drawer: NavbarDisgn(),
      body: Center(
        child: Column(
          children: [
            Text('data')
          ],
        ),
      ),
    );
  }
}