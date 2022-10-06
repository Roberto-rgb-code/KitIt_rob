import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitit/resourses/exceReader.dart';
import 'package:kitit/service/MySQLConnection.dart';
import 'package:kitit/service/datos_predios.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:kitit/widgets/modal_window.dart';

import '../widgets/drawer.dart';

class Map1 extends StatefulWidget {
  Map1({Key? key}) : super(key: key);

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
  // Set<Polygon> _polygonSet = Set<Polygon>();
  Set<Polygon> _polygonSet = new Set();

  List lista_geometry = [];

  @override
  final TextEditingController _textLugar = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  int contador = 0;
  LatLng? postionOnTap;
  double size_word = 17;
  late LatLng latlon1;

  final Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.6599162, -103.3450723),
    zoom: 11,
  );

  ValueNotifier<String> direccion = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    // _textLugar.text = "Jesus Garcia 3020";
    // final TextEditingController textLugar = TextEditingController();

    String? address;

    var device_data = MediaQuery.of(context);

    Completer<GoogleMapController> _controller = Completer();

    void moveCamera(double lat, double long) async {
      print('Entro a move camera');
      // double lat = 20.7016358;
      // double long = -103.3867676;

      final GoogleMapController controller = await _controller.future;

      LatLng latLngPosition = LatLng(lat, long);

      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLngPosition,
            zoom: 20,
          ),
        ),
      );

      setState(() {
        final id = _markers.length.toString();
        final markerId = MarkerId(id);

        final marker = Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          markerId: markerId,
          position: latLngPosition,
          anchor: const Offset(0.5, 1),
          onTap: () {
            _markersController.sink.add(id);
            latlon1 = latLngPosition;
          },
        );

        _markers[markerId] = marker;
      });
    }

    Set<Polygon> myPolygon(List lista_geometry) {
   
      print("lista que viene de DB -----------------------------");
      print(lista_geometry.length);
      int conta = 0;
      var aux;
      for (List lista in lista_geometry) {
        print("lista en for each ------------------------");
        print(lista);
        List<LatLng> polygonCoords = geometry_data(lista);

        _polygonSet.add(
          Polygon(
              polygonId: PolygonId('test $conta'),
              points: polygonCoords,
              consumeTapEvents: true,
              zIndex: 1,
              strokeColor: Colors.red.shade600,
              strokeWidth: 5,
              fillColor: Colors.red.shade100,
              onTap: () {}),
        );

        conta = conta + 1;
      }

      return _polygonSet;
    }

    GoogleMap mapa = GoogleMap(
      mapType: MapType.normal,
      // zoomControlsEnabled: false,

      polygons: _polygonSet,
      onTap: onTap,
      markers: markers,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );

    getLocation() async {
      List<Location> locations =
          await locationFromAddress("${_textLugar.text}, Guadalajara, Jal.");

      // await locationFromAddress("Jesus garcia 3020, Guadalajara, Jal.");

      return locations;
    }

    return Scaffold(
      drawer: const DrawerWidget(),
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: device_data.size.width,
                  height: device_data.size.height,
                  child: mapa,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 7),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                margin: const EdgeInsets.only(top: 70, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: device_data.size.width * 0.7,
                      child: TextField(
                        controller: _textLugar,
                        onChanged: (value) {
                          direccion.value = value;
                          print(direccion.value);
                        },
                        decoration: const InputDecoration(
                            labelText: "Ingrese su direccion",
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.none, width: 0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)))),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          // print('ENTRE AL ZOOM');

                          print('Direccion: ');
                          print(direccion.value);

                          final locations = await getLocation();

                          LatLng latLngPosition = LatLng(
                              locations[0].latitude, locations[0].longitude);

                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                  latLngPosition.latitude,
                                  latLngPosition.longitude);
                          //placemarks[0].postalCode
                          final resultados = await MySQLConnector.getData(
                              placemarks[0].postalCode);

                          setState(() {
                            myPolygon(resultados);
                            postionOnTap = latLngPosition;
                            if (contador == 0) {
                              contador += 1;

                              final id = _markers.length.toString();
                              final markerId = MarkerId(id);

                              final marker = Marker(
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueAzure),
                                markerId: markerId,
                                position: latLngPosition,
                                anchor: const Offset(0.5, 1),
                                onTap: () {
                                  _markersController.sink.add(id);
                                  latlon1 = latLngPosition;
                                },
                              );

                              _markers[markerId] = marker;
                            }

                            // });
                          });
                        },
                        child: const Icon(Icons.search))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsetsDirectional.only(start: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              onPressed: () {
                _polygonSet.clear();
                _textLugar.clear();

                setState(() {
                  _markers.clear();
                  contador = 0;
                });
              },
              child: const Icon(Icons.delete),
            ),
            const Divider(height: 50),
            Builder(
              builder: (context) {
                if (contador == 0) {
                  return const FloatingActionButton(
                    onPressed: null,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.remove_red_eye),
                  );
                } else {
                  return FloatingActionButton(
                    child: const Icon(Icons.remove_red_eye),
                    onPressed: () async {
                      print('Posicion colocada:::::::::::::::::::: ');
                      print(postionOnTap!.latitude);
                      print(postionOnTap!.longitude);

                      List<double> coordsUTM =
                          await ExcelReader.modifyLatAndLon(
                              postionOnTap!.latitude, postionOnTap!.longitude);

                      print('CORDENADAS UTM AAAAAAAAAAAAAAAAAAA');
                      print(coordsUTM);

                      data_predio_cordenada(coordsUTM).then(
                        (value) {
                          modal_window modal = modal_window(context, size_word);
                          if (value.length == 0) {
                            //redondeo de cus
                            modal.venta_modal_error();
                          } else {
                            modal.venta_modal_info(value, device_data);
                          }
                        },
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void onTap(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (contador == 0) {
      contador += 1;
      print(contador);
      setState(() {
        postionOnTap = position;
        // _textLugar.text = transformAddress(placemarks[0].street!);

        final id = _markers.length.toString();
        final markerId = MarkerId(id);

        final marker = Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          markerId: markerId,
          position: position,
          anchor: const Offset(0.5, 1),
          onTap: () {
            _markersController.sink.add(id);
            latlon1 = position;
          },
          draggable: true,
          onDragEnd: (newPosition) {
            //print("el marcador se puso en las longitudes $newPosition");
            print("latitud ");

            position = newPosition;

            print("POSI EN LA QUE PUSISTE EL MARCADOR WEY $position");
          },
        );

        _markers[markerId] = marker;
      });
    }
  }

  

  List<LatLng> geometry_data(List data) {
    var data_geometry = data;
    List<LatLng> polygonCoords = [];

    var new_list = data[0].replaceAll(" ", "").split(",");

    while (new_list.isNotEmpty) {
      var lat = double.parse(new_list.removeLast());
      var lon = double.parse(new_list.removeLast());
      polygonCoords.add(LatLng(lat, lon));
    }

    return polygonCoords;
  }
}
