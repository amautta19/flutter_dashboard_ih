import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/index_screen_provider.dart';
import 'package:provider/provider.dart';

class NavbarDisgn extends StatefulWidget {
  const NavbarDisgn({super.key});

  @override
  State<NavbarDisgn> createState() => _NavbarDisgnState();
}

class _NavbarDisgnState extends State<NavbarDisgn> {
  @override
  Widget build(BuildContext context) {
  final indexScreenProvider = Provider.of<IndexScreenProvider>(context);
    return Drawer(
      child: Container(
        color: Color(0xFFF5F5F5),
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlobalText('Dashboard Procesos', fontSize: 24, color: ColorDefaults.primaryBlue, fontWeight: FontWeight.bold,),
                  const SizedBox(height: 10,),
                  Expanded(child: Image.asset('assets/images/arca_logo.png')),
                ],
              ),
            ),
            items('Pozos', indexScreenProvider, context, 0),
            const SizedBox(height: 20,),
            items('Manifold',indexScreenProvider, context,1),
            const SizedBox(height: 20,),
            items('Estaciones CIP', indexScreenProvider, context, 2),
            const SizedBox(height: 20,),
            items('Ósmosis', indexScreenProvider, context, 3),
            const SizedBox(height: 20,),
            items('Filtros Pulidores', indexScreenProvider, context, 4)
          ],
        ),
        
      ),
    );
  }

  ListTile items(String name,IndexScreenProvider indexScreenProvider, BuildContext context, int index) {
    return ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: GlobalText(
              name,
              fontSize: 20,
              color: indexScreenProvider.getIndexClicked == index
                ? ColorDefaults.primaryBlue
                : ColorDefaults.darkPrimary,
              fontWeight: indexScreenProvider.getIndexClicked == index
                ? FontWeight.bold
                : FontWeight.normal,
            ),
            onTap: (){
              indexScreenProvider.updateIndexClicked(index);
              Navigator.pop(context);
            }
          );
  }
}