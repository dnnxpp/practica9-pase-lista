import 'dart:convert';

import 'package:flutter/foundation.dart';

// Si pruebas en un celular físico (Wi-Fi), escribe aquí la IP de tu PC. Ejemplo: '192.168.1.50'
const String ipCelularFisico = '';

// Dirección de la API según la plataforma donde corre la app
String get baseUrl {
  if (ipCelularFisico != '') {
    return 'http://$ipCelularFisico:8000';
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000'; // emulador de Android Studio
  }
  return 'http://127.0.0.1:8000'; // Flutter Web, Windows, macOS
}

// Guarda al usuario que inició sesión (lo que responde /Login)
class Sesion {
  static Map<String, dynamic>? usuario;

  static int get id => usuario == null ? 0 : usuario!['id_usr'];
  static String get nombre => usuario == null ? '' : usuario!['nom_usr'];
  static String get correo => usuario == null ? '' : usuario!['mail'];
  // tip_usu: 1 = visitante, 2 = administrador
  static bool get esAdmin => usuario != null && usuario!['tip_usu'] == 2;
}

// Saca el mensaje de error que manda FastAPI en el campo "detail"
String mensajeError(String cuerpo) {
  try {
    final datos = jsonDecode(cuerpo);
    if (datos is Map && datos['detail'] is String) {
      return datos['detail'];
    }
    return 'Revisa los datos ingresados';
  } catch (e) {
    return 'Error inesperado';
  }
}