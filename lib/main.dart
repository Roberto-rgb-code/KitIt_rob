import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitit/pages/page_modal_window.dart';
import 'package:kitit/pages/map.dart';


void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Info Ruta ',
      debugShowCheckedModeBanner: false,
      initialRoute: 'map',
      routes: 
      {
      'map': (BuildContext context) => Map1(),
      }
    );
  }
} 