import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class PerfilScreen extends StatefulWidget {
  final int idUsuario;

  const PerfilScreen({super.key, required this.idUsuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  Map<String, dynamic>? _usuario;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    super.dispose();
  }

  void _mostrar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // GET /usuarios/{id}
  Future<void> _cargar() async {
    try {
      final respuesta = await http.get(Uri.parse('$baseUrl/usuarios/${widget.idUsuario}'));
      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
        setState(() {
          _usuario = datos;
          _nombre.text = datos['nom_usr'];
          _direccion.text = datos['dir_usr'] ?? '';
        });
      } else {
        _mostrar(mensajeError(utf8.decode(respuesta.bodyBytes)));
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }

    if (mounted) setState(() => _cargando = false);
  }

  // PUT /usuarios/{id}
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    try {
      final respuesta = await http.put(
        Uri.parse('$baseUrl/usuarios/${widget.idUsuario}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom_usr': _nombre.text.trim(),
          'dir_usr': _direccion.text.trim(),
        }),
      );
      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        // Si es mi propio perfil, actualiza también la sesión
        if (widget.idUsuario == Sesion.id) {
          Sesion.usuario = jsonDecode(utf8.decode(respuesta.bodyBytes));
        }
        _mostrar('Datos actualizados');
        Navigator.pop(context, true);
        return;
      } else {
        _mostrar(mensajeError(utf8.decode(respuesta.bodyBytes)));
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }

    if (mounted) setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    final tipo = _usuario != null && _usuario!['tip_usu'] == 2 ? 'Administrador' : 'Visitante';

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _usuario == null
              ? const Center(child: Text('No se encontró el usuario'))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: Text(_usuario!['mail']),
                              subtitle: Text(tipo),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nombre,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (valor) {
                                if (valor == null || valor.trim().isEmpty) {
                                  return 'Escribe un nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _direccion,
                              decoration: const InputDecoration(
                                labelText: 'Dirección',
                                prefixIcon: Icon(Icons.home),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _guardando ? null : _guardar,
                                child: const Text('Guardar cambios'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}