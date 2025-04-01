import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.green[800],
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Inventario TI',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(LucideIcons.monitor),
                  title: Text('Equipos Generales'),
                ),
                ListTile(
                  leading: Icon(LucideIcons.monitorSmartphone),
                  title: Text('Computacionales'),
                ),
                ListTile(
                  leading: Icon(LucideIcons.smartphone),
                  title: Text('Celulares'),
                ),
                ListTile(
                  leading: Icon(LucideIcons.printer),
                  title: Text('Impresoras'),
                ),
                ListTile(
                  leading: Icon(LucideIcons.history),
                  title: Text('Historial'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
