import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/presentation/main_view.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qskfiowkylkfqckfokqy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFza2Zpb3dreWxrZnFja2Zva3F5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MTc0MTMsImV4cCI6MjA4ODI5MzQxM30.ZaMpdUWEY0eAydVnZeuA0ns4uSwXotx21FVhfFT4yYY', 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Llamando a los providers
        ChangeNotifierProvider(create: (_) => FilterMonthProvider()), // Filtro por mes
        ChangeNotifierProvider(create: (_) => FilterElement()), // Filtro por elemento del manifold
        ChangeNotifierProvider(create: (_) => FilterDayProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: ColorDefaults.darkPrimary
        ),
        home: const WindowsTableScreen(),
      ),
    );
  }
}

class WindowsTableScreen extends StatefulWidget {
  const WindowsTableScreen({super.key});
  @override
  State<WindowsTableScreen> createState() => _WindowsTableScreenState();
}

class _WindowsTableScreenState extends State<WindowsTableScreen> {

  @override
  Widget build(BuildContext context) {
    return MainView();
  }

}
