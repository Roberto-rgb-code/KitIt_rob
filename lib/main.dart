import 'dart:io';
import 'package:kitit/providers/polygons_data.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:kitit/pages/page_modal_window.dart';
import 'package:kitit/pages/map.dart';
import 'package:kitit/resourses/exceReader.dart';
import 'package:kitit/service/MySQLConnection.dart';

void main() async {
  MySQLConnector();
  WidgetsFlutterBinding.ensureInitialized();

  await ExcelReader.init();

  HttpOverrides.global = new MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'z',
        debugShowCheckedModeBanner: false,
        initialRoute: 'map',
        routes: {
          'map': (BuildContext context) => Map1(),
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
