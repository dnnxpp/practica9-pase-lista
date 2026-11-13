import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

// Formulario para crear (blog == null) o editar una publicación. Solo administrador.
class BlogFormScreen extends StatefulWidget {
  final dynamic blog;

  const BlogFormScreen({super.key, this.blog});

  @override
  State<BlogFormScreen> createState() => _BlogFormScreenState();
}

class _BlogFormScreenState extends State<BlogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _desc = TextEditingController();
  final _img = TextEditingController();
  final _tags = TextEditingController();
  bool _guardando = false;

  bool get _esEdicion => widget.blog != null;

  @override
  void initState() {
    super.initState();
    // Si es edición, llena los campos con los datos de la publicación
    if (_esEdicion) {
      _titulo.text = widget.blog['titulo'] ?? '';
      _desc.text = widget.blog['desc'] ?? '';
      _img.text = widget.blog['img'] ?? '';
      _tags.text = widget.blog['tags'] ?? '';
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _desc.dispose();
    _img.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _mostrar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // POST /blogs?id_admin=...  o  PUT /blogs/{id}?id_admin=...
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    try {
      final cuerpo = jsonEncode({
        'titulo': _titulo.text.trim(),
        'desc': _desc.text.trim(),
        'img': _img.text.trim(),
        'tags': _tags.text.trim(),
      });

      http.Response respuesta;
      if (_esEdicion) {
        final url = Uri.parse('$baseUrl/blogs/${widget.blog['id_blog']}')
            .replace(queryParameters: {'id_admin': '${Sesion.id}'});
        respuesta = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: cuerpo,
        );
      } else {
        final url = Uri.parse('$baseUrl/blogs')
            .replace(queryParameters: {'id_admin': '${Sesion.id}'});
        respuesta = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: cuerpo,
        );
      }
      if (!mounted) return;

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        _mostrar(_esEdicion ? 'Publicación actualizada' : 'Publicación creada');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar publicación' : 'Nueva publicación'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titulo,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Escribe un título';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _desc,
                    maxLength: 500,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _img,
                    decoration: const InputDecoration(
                      labelText: 'Imagen (nombre del archivo)',
                      prefixIcon: Icon(Icons.image),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tags,
                    decoration: const InputDecoration(
                      labelText: 'Categorías (separadas por coma)',
                      prefixIcon: Icon(Icons.tag),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_esEdicion ? 'Guardar cambios' : 'Crear publicación'),
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