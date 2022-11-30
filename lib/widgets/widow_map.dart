import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:kitit/pages/map.dart';
import 'package:kitit/providers/polygons_data.dart';
import 'package:provider/provider.dart';

import '../assets/colors.dart';

class window_map extends StatefulWidget {
  var data;

  Set<Polygon> listaPolygons;
  window_map({
    super.key,
    required this.data,
    required this.listaPolygons,
  });

  @override
  State<window_map> createState() => _window_mapState();
}

class _window_mapState extends State<window_map> {
  StreamController<String> controller = new StreamController<String>();
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: DesingColors.orange,
        ),
        child: SizedBox(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 15),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.girl, color: Colors.white),
                      title: Text(
                        "Femenino: ${widget.data["f"]}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.man, color: Colors.white),
                      title: Text(
                        "Masculino: ${widget.data["m"]}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people, color: Colors.white),
                      title: Text(
                        "Total: ${widget.data["t"]}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
