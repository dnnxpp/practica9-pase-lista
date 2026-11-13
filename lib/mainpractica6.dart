import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Formulario con Validación",
      theme: ThemeData(primarySwatch: Colors.orange),
      home: FormularioPage(),
    );
  }
}

class FormularioPage extends StatefulWidget {
  const FormularioPage({super.key});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();

  String nombre = "";
  String correo = "";
  String contrasena = "";
  String telefono = ""; // Paso 3.1: nuevo campo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Formulario")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo Nombre
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa tu nombre";
                  }
                  return null;
                },
                onSaved: (value) => nombre = value!,
              ),
              SizedBox(height: 20),

              // Campo Correo
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Correo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa tu correo";
                  } else if (!value.contains("@")) {
                    return "Ingresa un correo válido";
                  }
                  return null;
                },
                onSaved: (value) => correo = value!,
              ),
              SizedBox(height: 20),

              // Campo Contraseña
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa una contraseña";
                  } else if (value.length < 6) {
                    return "La contraseña debe tener al menos 6 caracteres";
                  }
                  return null;
                },
                onSaved: (value) => contrasena = value!,
              ),
              SizedBox(height: 20),

              // Paso 3.1: Campo Teléfono
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Teléfono",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa tu teléfono";
                  } else if (value.length < 10) {
                    return "El teléfono debe tener 10 dígitos";
                  }
                  return null;
                },
                onSaved: (value) => telefono = value!,
              ),
              SizedBox(height: 30),

              // Botón Enviar
              ElevatedButton(
                // Paso 3.2: estilo del botón
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: Text("Enviar"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResumenPage(
                          nombre: nombre,
                          correo: correo,
                          contrasena: contrasena,
                          telefono: telefono,
                        ),
                      ),
                    );
                    // Paso 3.4: reset del formulario
                    _formKey.currentState!.reset();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de resumen
class ResumenPage extends StatelessWidget {
  final String nombre;
  final String correo;
  final String contrasena;
  final String telefono;

  const ResumenPage(
      {super.key,
      required this.nombre,
      required this.correo,
      required this.contrasena,
      required this.telefono});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resumen de Datos")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Nombre: $nombre", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Correo: $correo", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            // Paso 3.3: contraseña oculta con asteriscos
            Text("Contraseña: ${'*' * contrasena.length}",
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Teléfono: $telefono", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}