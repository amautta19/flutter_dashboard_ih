import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/presentation/estaciones_cip/estaciones_cip_screen.dart';
import 'package:flutter_dashboard_ih/presentation/fiiltros_pulidores/filtros_pulidores_screen.dart';
import 'package:flutter_dashboard_ih/presentation/lavadoras/lavadoras_screen.dart';
import 'package:flutter_dashboard_ih/presentation/manifold/main_view.dart';
import 'package:flutter_dashboard_ih/presentation/osmosis/osmosis_screen.dart';
import 'package:flutter_dashboard_ih/presentation/pozos_vista/pozo_screen.dart';
import 'package:flutter_dashboard_ih/presentation/version_update/version_update_screen.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/providers/index_screen_provider.dart';
import 'package:flutter_dashboard_ih/providers/umbrales_provider.dart';
import 'package:flutter_dashboard_ih/providers/version_app_provider.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

void main() async {

  // Se configura como pantalla grande la aplicación
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1080, 720),
    center: true,
    title: 'Dashboard Procesos - Planta Pucusana',
    titleBarStyle: TitleBarStyle.normal
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async{
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qskfiowkylkfqckfokqy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFza2Zpb3dreWxrZnFja2Zva3F5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MTc0MTMsImV4cCI6MjA4ODI5MzQxM30.ZaMpdUWEY0eAydVnZeuA0ns4uSwXotx21FVhfFT4yYY', 
  );
  runApp(
    MultiProvider(
      providers: [
        // Llamando a los providers
        ChangeNotifierProvider(create: (_) => VersionAppProvider()),
        ChangeNotifierProvider(create: (_) => FilterMonthProvider()), // Filtro por mes
        ChangeNotifierProvider(create: (_) => FilterElementProvider()), // Filtro por elemento del manifold
        ChangeNotifierProvider(create: (_) => FilterDayProvider()),
        ChangeNotifierProvider(create: (_) => IndexScreenProvider()),
        // Se inicializa el provider para obtener la tabla de los umbrales
        ChangeNotifierProvider(
          create: (_) => UmbralesProvider()..actualizarUmbrales()
        )
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? newVersion; // Usamos null para saber que aún no carga
  String? actualVersion;

  @override
  void initState() {
    super.initState();
    _initAppLogic();
  }

  Future<void> _initAppLogic() async {
    // 1. Obtener versión local
    final info = await PackageInfo.fromPlatform();
    final vLocal = info.version;

    // 2. Obtener versión remota
    final vRemote = await SupabaseServices().getVersionNew();

    // 3. Guardar en el Provider solo la actual
    if (!mounted) return;
    context.read<VersionAppProvider>().updateVersionApp(vLocal);

    // 4. Actualizar variables locales para el build
    setState(() {
      actualVersion = vLocal;
      newVersion = vRemote;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mientras esperamos los datos, mostramos un splash o loading
    if (actualVersion == null || newVersion == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Ahora sí, comparamos con seguridad
    // Si la versión actual es IGUAL a la nueva, entramos a la app (WindowsTableScreen)
    // Si son DIFERENTES, mandamos a actualizar.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: ColorDefaults.darkPrimary,
      ),
      home: (actualVersion == newVersion)
          ? const WindowsTableScreen()
          : VersionUpdateScreen(versionNew: newVersion!),
    );
  }
}

class WindowsTableScreen extends StatefulWidget {
  const WindowsTableScreen({super.key});
  @override
  State<WindowsTableScreen> createState() => _WindowsTableScreenState();
}

class _WindowsTableScreenState extends State<WindowsTableScreen> {

  final screens = [
    PozoScreen(),
    MainView(),
    EstacionesCipScreen(),
    OsmosisScreen(),
    FiltrosPulidoresScreen(),
    LavadorasScreen()
  ];
  @override
  Widget build(BuildContext context) {
    final indexScreenProvider = Provider.of<IndexScreenProvider>(context);
    final umbralesProvider = Provider.of<UmbralesProvider>(context);
    // Espear la carga de la tabla de umbrales
    if(umbralesProvider.isLoading && umbralesProvider.tablaUmbrales.isEmpty){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: ColorDefaults.primaryBlue,),
        ),
      );
    }
    
    return screens[indexScreenProvider.getIndexClicked];
  }

}
