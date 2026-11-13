// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlumnoList extends StatefulWidget {
  const AlumnoList({super.key});

  @override
  _AlumnoListState createState() => _AlumnoListState();
}

class _AlumnoListState extends State<AlumnoList> {
  List<dynamic> alumnos = [];

  Future<void> cargarAlumnos() async {
    final url = Uri.parse('http://10.0.2.2:8000/alumnos/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        alumnos = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar alumnos: ${response.statusCode}',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarAlumnos();
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
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Lista de Alumnos',
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
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: alumnos.length,
          itemBuilder: (context, index) {
            final alumno = alumnos[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    alumno['id'].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  alumno['nombre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Edad: ${alumno['edad']}'),
                    Text('Carrera: ${alumno['carrera']}'),
                  ],
                ),
                trailing: const Icon(
                  Icons.school,
                  color: Colors.indigo,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Volver al formulario',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}