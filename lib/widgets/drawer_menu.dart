import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../screens/consumibles_page.dart';
import '../screens/equipos_generales_view.dart';

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
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.monitor),
                  title: const Text('Equipos Generales'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EquiposGeneralesPage(),
                      ),
                    );
                  },
                ),
                const ListTile(
                  leading: Icon(LucideIcons.monitorSmartphone),
                  title: Text('Computacionales'),
                ),
                const ListTile(
                  leading: Icon(LucideIcons.smartphone),
                  title: Text('Celulares'),
                ),
                const ListTile(
                  leading: Icon(LucideIcons.printer),
                  title: Text('Impresoras'),
                ),
                ListTile(
                  leading: const Icon(LucideIcons.package),
                  title: const Text('Consumibles'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConsumiblesPage(),
                      ),
                    );
                  },
                ),
                const ListTile(
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
