import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App con Menú",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menú Principal")),
      drawer: const MenuLateral(),
      body: const Center(
        child: Text(
          "Bienvenido a la App con Menú 🚀",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
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
            leading: const Icon(Icons.home),
            title: const Text("Inicio"),
            onTap: () {
              Navigator.pop(context); // cierra el menú
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Catálogo"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CatalogoPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text("Formulario"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FormularioPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}


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
      appBar: AppBar(title: const Text("Catálogo de Productos")),
      drawer: const MenuLateral(),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: Text(productos[index]),
            ),
          );
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulario")),
      drawer: const MenuLateral(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su nombre";
                  }
                  return null;
                },
                onSaved: (value) => nombre = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Correo"),
                validator: (value) {
                  if (value == null || !value.contains("@")) {
                    return "Ingrese un correo válido";
                  }
                  return null;
                },
                onSaved: (value) => correo = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Enviar"),
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