// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioCtrl = TextEditingController();
  final contrasenaCtrl = TextEditingController();
  String mensaje = '';

  Future<void> iniciarSesion() async {
    final url = Uri.parse('http://10.0.2.2:8000/login');
    final respuesta = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario': usuarioCtrl.text,
        'contrasena': contrasenaCtrl.text,
      }),
    );

    if (respuesta.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/form');
    } else {
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      setState(() {
        mensaje = datos['detail'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usuarioCtrl,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: contrasenaCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: iniciarSesion,
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 10),
            Text(mensaje, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}