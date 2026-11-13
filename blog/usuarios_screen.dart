import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'perfil_screen.dart'; 
import 'registro_screen.dart';

// Pantalla solo para el administrador
class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<dynamic> _usuarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _mostrar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // GET /usuarios?id_admin=...
  Future<void> _cargar() async {
    setState(() => _cargando = true);

    try {
      final url = Uri.parse('$baseUrl/usuarios')
          .replace(queryParameters: {'id_admin': '${Sesion.id}'});
      final respuesta = await http.get(url);
      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        setState(() {
          _usuarios = jsonDecode(utf8.decode(respuesta.bodyBytes));
        });
      } else {
        _mostrar(mensajeError(utf8.decode(respuesta.bodyBytes)));
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }

    if (mounted) setState(() => _cargando = false);
  }

  // DELETE /usuarios/{id}?id_admin=...
  Future<void> _eliminar(dynamic usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar a ${usuario['nom_usr']} y todos sus comentarios?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      final url = Uri.parse('$baseUrl/usuarios/${usuario['id_usr']}')
          .replace(queryParameters: {'id_admin': '${Sesion.id}'});
      final respuesta = await http.delete(url);
      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        _mostrar('Usuario eliminado');
        _cargar();
      } else {
        _mostrar(mensajeError(utf8.decode(respuesta.bodyBytes)));
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }
  }

  Future<void> _editar(dynamic usuario) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PerfilScreen(idUsuario: usuario['id_usr'])),
    );
    _cargar();
  }

  Future<void> _agregar() async {
    final registrado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistroScreen()),
    );
    if (registrado == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregar,
        child: const Icon(Icons.person_add),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView.builder(
                itemCount: _usuarios.length,
                itemBuilder: (context, indice) {
                  final usuario = _usuarios[indice];
                  final esAdministrador = usuario['tip_usu'] == 2;
                  final esYo = usuario['id_usr'] == Sesion.id;
                  final direccion = usuario['dir_usr'] ?? 'Sin dirección';
                  final tipo = esAdministrador ? 'Administrador' : 'Visitante';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(esAdministrador ? Icons.shield : Icons.person),
                      ),
                      title: Text(usuario['nom_usr']),
                      subtitle: Text('${usuario['mail']}\n$tipo · $direccion'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editar(usuario),
                          ),
                          // El administrador no se puede borrar a sí mismo
                          if (!esYo)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _eliminar(usuario),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}