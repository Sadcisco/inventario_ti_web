import 'package:flutter/material.dart';

class TestDialogPage extends StatelessWidget {
  const TestDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Diálogo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _mostrarDialogo(context);
          },
          child: const Text('Mostrar Diálogo'),
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Diálogo de Prueba'),
          content: const Text('Este es un diálogo de prueba'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
