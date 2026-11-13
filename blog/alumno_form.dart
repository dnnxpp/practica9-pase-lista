// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlumnoForm extends StatefulWidget {
  const AlumnoForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AlumnoFormState createState() => _AlumnoFormState();
}

class _AlumnoFormState extends State<AlumnoForm> {
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _carreraController = TextEditingController();

  Future<void> insertarAlumno() async {
    final url = Uri.parse('http://10.0.2.2:8000/alumnos/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': _nombreController.text,
        'edad': int.tryParse(_edadController.text),
        'carrera': _carreraController.text,
      }),
    );

    print("response body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final alumnoIns = jsonDecode(response.body);
      final id = alumnoIns['id'];
      final nombre = alumnoIns['nombre'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alumno insertado: $id - $nombre'),
        ),
      );

      _nombreController.clear();
      _edadController.clear();
      _carreraController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al insertar'),
        ),
      );
    }

    print(response.statusCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
              ], // azul oscuro a medio
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Insertar Alumno',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2196F3),
              Color(0xFF0D47A1),
            ], // azul claro a azul oscuro
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                  ),
                ),
                TextField(
                  controller: _edadController,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _carreraController,
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: insertarAlumno,
                  child: const Text('Insertar'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/lista'),
                  child: const Text('Ver lista de alumnos'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}