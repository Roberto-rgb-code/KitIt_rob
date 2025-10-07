// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';

// ==== Tus imports existentes ====
import 'package:kitit/providers/polygons_data.dart';
import 'package:kitit/service/dataSave.dart';
import 'package:kitit/widgets/onBording.dart';
import 'package:provider/provider.dart';
import 'package:kitit/pages/map.dart';
import 'package:kitit/resourses/exceReader.dart';
import 'package:kitit/service/MySQLConnection.dart';

// ==== Firebase ====
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ==== Login/Register ====
import 'package:kitit/pages/auth/login_page.dart';
import 'package:kitit/pages/auth/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <- primero

  // ✅ Inicializa Firebase usando las opciones generadas por FlutterFire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Si usas shared_preferences dentro de DataSave, ahora no truena.
  bool? entro = await DataSave.getInicio();
  entro ??= false;

  // Inicializa tu conector MySQL (asegúrate de que maneje errores internos)
  try {
    MySQLConnector();
  } catch (_) {}

  // Evitar que falle el arranque si GSheets no está configurado
  try {
    await ExcelReader.init();
  } catch (_) {}

  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp(entro));
}

class MyApp extends StatelessWidget {
  late bool entro;
  MyApp(bool entro, {super.key}) {
    this.entro = entro;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExitoXY',
      debugShowCheckedModeBanner: false,
      // 👉 Primera vista: Login
      initialRoute: 'login',
      routes: {
        'login': (BuildContext context) => LoginPage(),
        'register': (BuildContext context) => RegisterPage(),
        'map': (BuildContext context) => Map1(),
        'onBording': (BuildContext context) => const onBordingData(),
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
