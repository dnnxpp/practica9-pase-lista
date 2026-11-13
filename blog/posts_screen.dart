import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'blog_form_screen.dart';
import 'login_screen.dart';
import 'perfil_screen.dart';
import 'post_detail_screen.dart';
import 'usuarios_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> _blogs = [];
  List<dynamic> _tags = [];
  String? _tagSeleccionado;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _mostrar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // GET /tags y GET /blogs (con el filtro de categoría si hay uno elegido)
  Future<void> _cargar() async {
    setState(() => _cargando = true);

    try {
      final respuestaTags = await http.get(Uri.parse('$baseUrl/tags'));

      var urlBlogs = Uri.parse('$baseUrl/blogs');
      if (_tagSeleccionado != null) {
        urlBlogs = urlBlogs.replace(queryParameters: {'tag': _tagSeleccionado!});
      }
      final respuestaBlogs = await http.get(urlBlogs);
      if (!mounted) return;

      if (respuestaTags.statusCode == 200 && respuestaBlogs.statusCode == 200) {
        setState(() {
          _tags = jsonDecode(utf8.decode(respuestaTags.bodyBytes));
          _blogs = jsonDecode(utf8.decode(respuestaBlogs.bodyBytes));
        });
      } else {
        _mostrar('No se pudieron cargar las publicaciones');
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }

    if (mounted) setState(() => _cargando = false);
  }

  // DELETE /blogs/{id}?id_admin=...
  Future<void> _eliminarBlog(dynamic blog) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: Text('¿Eliminar "${blog['titulo']}" y todos sus comentarios?'),
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
      final url = Uri.parse('$baseUrl/blogs/${blog['id_blog']}')
          .replace(queryParameters: {'id_admin': '${Sesion.id}'});
      final respuesta = await http.delete(url);
      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        _mostrar('Publicación eliminada');
        _cargar();
      } else {
        _mostrar(mensajeError(utf8.decode(respuesta.bodyBytes)));
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    }
  }

  Future<void> _abrirFormulario(dynamic blog) async {
    final guardado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlogFormScreen(blog: blog)),
    );
    if (guardado == true) _cargar();
  }

  void _cerrarSesion() {
    Sesion.usuario = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (ruta) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inicial = Sesion.nombre.isNotEmpty ? Sesion.nombre[0].toUpperCase() : '?';
    final tipo = Sesion.esAdmin ? 'Administrador' : 'Visitante';

    return Scaffold(
      appBar: AppBar(title: const Text('Who is Ale')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(Sesion.nombre),
              accountEmail: Text('${Sesion.correo} ($tipo)'),
              currentAccountPicture: CircleAvatar(child: Text(inicial)),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Publicaciones'),
              onTap: () => Navigator.pop(context),
            ),
            if (Sesion.esAdmin)
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Usuarios'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsuariosScreen()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PerfilScreen(idUsuario: Sesion.id),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
      floatingActionButton: Sesion.esAdmin
          ? FloatingActionButton(
              onPressed: () => _abrirFormulario(null),
              child: const Icon(Icons.add),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('Todos'),
                          selected: _tagSeleccionado == null,
                          onSelected: (_) {
                            setState(() => _tagSeleccionado = null);
                            _cargar();
                          },
                        ),
                      ),
                      for (final tag in _tags)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tag.toString()),
                            selected: _tagSeleccionado == tag.toString(),
                            onSelected: (_) {
                              setState(() => _tagSeleccionado = tag.toString());
                              _cargar();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _cargar,
                    child: _blogs.isEmpty
                        ? ListView(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(child: Text('No hay publicaciones')),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _blogs.length,
                            itemBuilder: (context, indice) {
                              final blog = _blogs[indice];
                              final descripcion = blog['desc'] ?? '';
                              final etiquetas = blog['tags'] ?? '';
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: const CircleAvatar(child: Icon(Icons.article)),
                                  title: Text(blog['titulo']),
                                  subtitle: Text('$descripcion\n#$etiquetas'),
                                  isThreeLine: true,
                                  trailing: Sesion.esAdmin
                                      ? PopupMenuButton<String>(
                                          onSelected: (opcion) {
                                            if (opcion == 'editar') {
                                              _abrirFormulario(blog);
                                            } else {
                                              _eliminarBlog(blog);
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem<String>(
                                              value: 'editar',
                                              child: Text('Editar'),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'eliminar',
                                              child: Text('Eliminar'),
                                            ),
                                          ],
                                        )
                                      : const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PostDetailScreen(idBlog: blog['id_blog']),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}