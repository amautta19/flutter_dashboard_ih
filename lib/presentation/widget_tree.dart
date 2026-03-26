import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/presentation/main_view.dart';
import 'package:flutter_dashboard_ih/presentation/pozos_vista/pozo_screen.dart';
import 'package:flutter_dashboard_ih/providers/index_screen_provider.dart';
import 'package:provider/provider.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final screens = [
    PozoScreen(),
    MainView()
  ];
  @override
  Widget build(BuildContext context) {
    final indexScreenProvider = Provider.of<IndexScreenProvider>(context);
    return  screens[indexScreenProvider.getIndexClicked];
  }
}