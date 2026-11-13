import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App con Barra de Herramientas",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

/// --------------------
/// 1. Pantalla principal (Inicio)
/// --------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraHerramientas(context, "Inicio"),
      drawer: MenuLateral(),
      body: Center(
        child: Text(
          "Bienvenido a la App con Barra de Herramientas 🚀",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// --------------------
/// 2. Barra de Herramientas (AppBar con acciones)
/// --------------------
PreferredSizeWidget barraHerramientas(BuildContext context, String titulo) {
  return AppBar(
    title: Text(titulo),
    actions: [
      IconButton(
        icon: Icon(Icons.search),
        tooltip: "Buscar",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Acción: Buscar")),
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.refresh),
        tooltip: "Refrescar",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Acción: Refrescar")),
          );
        },
      ),
      PopupMenuButton<String>(
        onSelected: (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Opción seleccionada: $value")),
          );
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: "Configuración",
            child: Text("Configuración"),
          ),
          PopupMenuItem(value: "Acerca de", child: Text("Acerca de")),
        ],
      ),
    ],
  );
}

/// --------------------
/// 3. Menú lateral
/// --------------------
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 64, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Menú de Prácticas",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Inicio"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text("Catálogo"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CatalogoPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text("Formulario"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormularioPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// --------------------
/// 4. Pantalla Catálogo
/// --------------------
class CatalogoPage extends StatelessWidget {
  const CatalogoPage({super.key});

  final List<String> productos = const [
    "Laptop",
    "Smartphone",
    "Audífonos",
    "Tablet",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraHerramientas(context, "Catálogo"),
      drawer: MenuLateral(),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text(productos[index]),
            ),
          );
        },
      ),
    );
  }
}

/// --------------------
/// 5. Pantalla Formulario
/// --------------------
class FormularioPage extends StatefulWidget {
  const FormularioPage({super.key});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = "";
  String correo = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraHerramientas(context, "Formulario"),
      drawer: MenuLateral(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Nombre"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su nombre";
                  }
                  return null;
                },
                onSaved: (value) => nombre = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Correo"),
                validator: (value) {
                  if (value == null || !value.contains("@")) {
                    return "Ingrese un correo válido";
                  }
                  return null;
                },
                onSaved: (value) => correo = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Enviar"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Datos: $nombre - $correo")),
                    );
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