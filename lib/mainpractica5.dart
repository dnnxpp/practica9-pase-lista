import 'package:flutter/material.dart';
 
void main() {
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lista Dinámica",
      theme: ThemeData(primarySwatch: Colors.green),
      home: PantallaLista(),
    );
  }
}
 
// Pantalla con lista
class PantallaLista extends StatelessWidget {
  PantallaLista({super.key});
 
  // Cada elemento tiene nombre, descripción e ícono
  final List<Map<String, dynamic>> elementos = [
    {"nombre": "Elemento 1", "descripcion": "Descripción del elemento 1", "icono": Icons.home},
    {"nombre": "Elemento 2", "descripcion": "Descripción del elemento 2", "icono": Icons.school},
    {"nombre": "Elemento 3", "descripcion": "Descripción del elemento 3", "icono": Icons.work},
    {"nombre": "Elemento 4", "descripcion": "Descripción del elemento 4", "icono": Icons.music_note},
    {"nombre": "Elemento 5", "descripcion": "Descripción del elemento 5", "icono": Icons.sports_soccer},
    {"nombre": "Elemento 6", "descripcion": "Descripción del elemento 6", "icono": Icons.camera_alt},
    {"nombre": "Elemento 7", "descripcion": "Descripción del elemento 7", "icono": Icons.book},
    {"nombre": "Elemento 8", "descripcion": "Descripción del elemento 8", "icono": Icons.map},
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Elementos")),
      body: ListView.builder(
        itemCount: elementos.length,
        itemBuilder: (context, index) {
          final elemento = elementos[index];
          return ListTile(
            leading: Icon(elemento["icono"]),
            title: Text(elemento["nombre"]),
            subtitle: Text(elemento["descripcion"]),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaDetalle(
                    nombre: elemento["nombre"],
                    descripcion: elemento["descripcion"],
                    icono: elemento["icono"], 
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
 
// Pantalla de detalles
class PantallaDetalle extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final IconData icono;
 
  const PantallaDetalle({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.icono,
  });
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 80, color: Colors.green),
            SizedBox(height: 20),
            // Imagen en el detalle (con respaldo si no carga)
            Image.network(
              "https://picsum.photos/300/200",
              width: 300,
              height: 200,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.image_not_supported, size: 80),
            ),
            SizedBox(height: 20),
            Text(
              "Has seleccionado: $nombre",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              descripcion,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
