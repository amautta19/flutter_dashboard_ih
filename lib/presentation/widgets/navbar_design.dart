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
        color: ColorDefaults.darkPrimary,
        child: Column(
          children: [
            DrawerHeader(
              child: GlobalText('Dashboard Procesos'),
            ),
            items('Pozos', indexScreenProvider, context, 0),
            const SizedBox(height: 20,),
            items('Manifold',indexScreenProvider, context,1),
            const SizedBox(height: 20,),
            items('Estaciones CIP', indexScreenProvider, context, 2)

          ],
        ),
        
      ),
    );
  }

  ListTile items(String name,IndexScreenProvider indexScreenProvider, BuildContext context, int index) {
    return ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            title: GlobalText(
              name,
              fontSize: 20,
              color: indexScreenProvider.getIndexClicked == index
                ? ColorDefaults.primaryBlue
                : ColorDefaults.whitePrimary
            ),
            onTap: (){
              indexScreenProvider.updateIndexClicked(index);
              Navigator.pop(context);
            }
          );
  }
}