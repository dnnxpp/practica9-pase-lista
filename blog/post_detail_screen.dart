import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class PostDetailScreen extends StatefulWidget {
  final int idBlog;

  const PostDetailScreen({super.key, required this.idBlog});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic>? _blog;
  List<dynamic> _comentarios = [];
  final _nuevoComentario = TextEditingController();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nuevoComentario.dispose();
    super.dispose();
  }

  void _mostrar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  String _formatearFecha(dynamic fecha) {
    final texto = fecha.toString().replaceFirst('T', ' ');
    return texto.length >= 16 ? texto.substring(0, 16) : texto;
  }

  // GET /blogs/{id} y GET /blogs/{id}/comentarios
  Future<void> _cargar() async {
    try {
      final respuestaBlog = await http.get(Uri.parse('$baseUrl/blogs/${widget.idBlog}'));
      final respuestaComentarios =
          await http.get(Uri.parse('$baseUrl/blogs/${widget.idBlog}/comentarios'));
      if (!mounted) return;

      if (respuestaBlog.statusCode == 200 && respuestaComentarios.statusCode == 200) {
        setState(() {
          _blog = jsonDecode(utf8.decode(respuestaBlog.bodyBytes));
          _comentarios = jsonDecode(utf8.decode(respuestaComentarios.bodyBytes));
        });
      } else {
        _mostrar('No se pudo cargar la publicación');
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }

    if (mounted) setState(() => _cargando = false);
  }

  // POST /comentarios
  Future<void> _enviarComentario() async {
    final texto = _nuevoComentario.text.trim();
    if (texto.isEmpty) return;

    try {
      final respuesta = await http.post(
        Uri.parse('$baseUrl/comentarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'comentario': texto,
          'usr_id': Sesion.id,
          'blog_id': widget.idBlog,
        }),
      );
      if (!mounted) return;

      if (respuesta.statusCode == 201) {
        _nuevoComentario.clear();
        _cargar();
      } else {
        _mostrar(mensajeError(utf8.decode(respuesta.bodyBytes)));
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }
  }

  // PUT /comentarios/{id}?id_usr=...
  Future<void> _editarComentario(dynamic comentario) async {
    final controlador = TextEditingController(text: comentario['comentario']);
    final nuevoTexto = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: controlador,
          maxLines: 3,
          maxLength: 500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controlador.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevoTexto == null || nuevoTexto.isEmpty) return;

    try {
      final url = Uri.parse('$baseUrl/comentarios/${comentario['id_com']}')
          .replace(queryParameters: {'id_usr': '${Sesion.id}'});
      final respuesta = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'comentario': nuevoTexto}),
      );
      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        _cargar();
      } else {
        _mostrar(mensajeError(utf8.decode(respuesta.bodyBytes)));
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }
  }

  // DELETE /comentarios/{id}?id_usr=...  (lo puede hacer su autor o el administrador)
  Future<void> _eliminarComentario(dynamic comentario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('¿Seguro que quieres eliminar este comentario?'),
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
      final url = Uri.parse('$baseUrl/comentarios/${comentario['id_com']}')
          .replace(queryParameters: {'id_usr': '${Sesion.id}'});
      final respuesta = await http.delete(url);
      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        _cargar();
      } else {
        _mostrar(mensajeError(utf8.decode(respuesta.bodyBytes)));
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _blog == null ? 'Publicación' : _blog!['titulo'];

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _blog == null
              ? const Center(child: Text('No se encontró la publicación'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Text(
                            _blog!['titulo'],
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_blog!['desc'] ?? ''),
                          const SizedBox(height: 8),
                          Text('#${_blog!['tags'] ?? ''}'),
                          const Divider(height: 32),
                          Text(
                            'Comentarios (${_comentarios.length})',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (_comentarios.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Aún no hay comentarios. ¡Escribe el primero!'),
                            ),
                          for (final comentario in _comentarios)
                            _tarjetaComentario(comentario),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nuevoComentario,
                                maxLength: 500,
                                decoration: const InputDecoration(
                                  hintText: 'Escribe un comentario',
                                  border: OutlineInputBorder(),
                                  counterText: '',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _enviarComentario,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _tarjetaComentario(dynamic comentario) {
    final esMio = comentario['usr_id'] == Sesion.id;
    final puedeBorrar = esMio || Sesion.esAdmin;
    final autor = comentario['nom_usr'] ?? 'Usuario';
    final texto = comentario['comentario'];
    final fecha = _formatearFecha(comentario['fecha']);

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(autor.toString()[0].toUpperCase())),
        title: Text(autor),
        subtitle: Text('$texto\n$fecha'),
        isThreeLine: true,
        trailing: puedeBorrar
            ? PopupMenuButton<String>(
                onSelected: (opcion) {
                  if (opcion == 'editar') {
                    _editarComentario(comentario);
                  } else {
                    _eliminarComentario(comentario);
                  }
                },
                itemBuilder: (_) => [
                  if (esMio)
                    const PopupMenuItem<String>(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'eliminar',
                    child: Text('Eliminar'),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}