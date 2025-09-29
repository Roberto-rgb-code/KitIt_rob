import 'dart:io';
import 'package:kitit/providers/polygons_data.dart';
import 'package:kitit/service/dataSave.dart';
import 'package:kitit/widgets/onBording.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:kitit/pages/map.dart';
import 'package:kitit/resourses/exceReader.dart';
import 'package:kitit/service/MySQLConnection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <- primero

  // Si usas shared_preferences dentro de DataSave, ahora no truena.
  bool? entro = await DataSave.getInicio();
  print("VALOR INICIa app____________________________________________________");
  print(entro);
  entro ??= false;

  // Inicializa tu conector MySQL (asegúrate de que maneje errores internos)
  MySQLConnector();

  // Evitar que falle el arranque si GSheets no está configurado
  try {
    print("Conectando a la hoja de calculo...");
    await ExcelReader.init();
    print("GSheets OK");
  } catch (e, st) {
    print("GSheets deshabilitado temporalmente: $e");
    // Opcional: log detallado
    // print(st);
  }

  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp(entro));
}


class MyApp extends StatelessWidget {
  late bool entro;
  MyApp(bool entro) {
    this.entro = entro;
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    print('holaaaaaaaaa soy entro xd _____________________________');
    print(entro);
    return MaterialApp(
        title: 'ExitoXY',
        debugShowCheckedModeBanner: false,
      //  initialRoute: entro ? 'map' : 'onBording',
        initialRoute: 'map',
        routes: {
          'map': (BuildContext context) => Map1(),
          'onBording': (BuildContext context) => const onBordingData()
        });
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
