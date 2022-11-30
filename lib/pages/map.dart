import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitit/assets/ColorPolygon.dart';
import 'package:kitit/assets/colors.dart';
import 'package:kitit/resourses/exceReader.dart';
import 'package:kitit/service/MySQLConnection.dart';
import 'package:kitit/service/datos_predios.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kitit/widgets/SliderM2.dart';
import 'package:kitit/widgets/demograficModal.dart';
import 'package:kitit/service/google_places.dart';
import 'package:kitit/widgets/modal_window.dart';
import 'package:kitit/widgets/polygons_metods.dart';
import 'package:kitit/widgets/widow_map.dart';
import 'package:kitit/service/DENUE_data.dart';
import '../widgets/SliderPrice.dart';
import '../widgets/markersComers.dart';

class Map1 extends StatefulWidget {
  Map1({Key? key}) : super(key: key);

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
//variables de google maps and polygons
  Set<Polygon> _polygonSet = new Set();
  Set<Polygon> _polygonSetDisable = new Set();
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  LatLng? postionOnTap;
  late LatLng latlon1;
  late Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();
  final _markersController = StreamController<String>.broadcast();

//controladores en general y banderas
  Stream<String> get onMarkerTap => _markersController.stream;
  @override
  final TextEditingController _textLugar = TextEditingController();
  final TextEditingController _textActividadEconomica = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  bool hammerIsTaped = false;
  bool hasPaintedAZone = false;
  bool window_visiviliti = false;
  String? postalCode;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.6599162, -103.3450723),
    zoom: 11,
  );

  ValueNotifier<String> direccion = ValueNotifier<String>('');
  ValueNotifier<String> actividadEconomica = ValueNotifier<String>('');
  ValueNotifier<bool> buttonDisable = ValueNotifier<bool>(true);
  ValueNotifier<bool> buttonAE = ValueNotifier<bool>(false);
  ValueNotifier<List<int>> totalHabitantes =
      ValueNotifier<List<int>>([0, 0, 0]);
  bool hasChangedFilter = false;

  final textFieldFocus = FocusNode();
  final textFieldFocus_actividad = FocusNode();

  int count_markers = 0;
  bool marker_llenos = false;

  @override
  Widget build(BuildContext context) {
    var deviceData = MediaQuery.of(context);

    Completer<GoogleMapController> _controller = Completer();

    void moveCamera(double lat, double long) async {
      print('Entro a move camera');
      // double lat = 20.7016358;
      // double long = -103.3867676;

      final GoogleMapController controller = await _controller.future;
      final icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'lib/_img/amarilloyblanco(1).png');

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
          icon: icon,
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

    getLocation() async {
      List<Location> locations =
          await locationFromAddress("${_textLugar.text}, Guadalajara, Jal.");

      // await locationFromAddress("Jesus garcia 3020, Guadalajara, Jal.");

      return locations;
    }

    void onTap(LatLng position) async {
      textFieldFocus.unfocus();
      setState(() {
        postionOnTap = LatLng(position.latitude, position.longitude);
      });

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'lib/_img/amarilloyblanco(1).png');

      print('ESTAS TAPEANDO EL MAPA');
      final resultados = await MySQLConnector.getData(placemarks[0].postalCode);
      print(
          "Poligonos pitnados on tap ________________________________________________________________________");
      if (resultados[0].length > 0) {
        for (Map element in resultados[2]) {
          totalHabitantes.value[0] += int.parse(element['t']);
          totalHabitantes.value[1] += int.parse(element['m']);
          totalHabitantes.value[2] += int.parse(element['f']);
        }

        if (!hasPaintedAZone) {
          var res_data =
              await MySQLConnector.getMarkersbyCP(placemarks[0].postalCode);

          setState(() {
            postalCode = placemarks[0].postalCode;
          });
          MarkersCom markerscom = MarkersCom(res_data);
          // ignore: use_build_context_synchronously
          final markersComers = await markerscom.printMarkersComers(
              _customInfoWindowController, context, deviceData);
          setState(() {
            hasPaintedAZone = true;
            myPolygon(resultados);

            for (Marker element in markersComers) {
              _markers[element.markerId] = element;
            }
          });
        }

        if (hammerIsTaped) {
          print('ESTAS TAPEANDO EL MAPA CON EL MARTILLO');
          setState(() {
            postionOnTap = position;

            // _textLugar.text = transformAddress(placemarks[0].street!);

            String id = 'hammerMaker';
            final markerId = MarkerId(id);

            final marker = Marker(
              icon: icon,
              markerId: markerId,
              position: position,
              zIndex: 2,
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
              },
            );

            _markers[markerId] = marker;
          });
          //AQUI ES DONDE LLAMAREMOS LA VENTANA MODAL
          modal_window modal = modal_window(context, 17);

          List<double> coordsUTM = await ExcelReader.modifyLatAndLon(
              position.latitude, position.longitude);

          final response = await data_predio_cordenada(coordsUTM);

          bool bandVenta = true;
          if (response.length == 0) {
            bandVenta = false;
          }
          modal.venta_modal_info(response, deviceData, bandVenta);
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se econtraron datos en el lugar seleccionado'),
          ),
        );
      }

      // POR SI QUIERES ALGUN OTRO IF
    }

    Set<Polygon> paintPolygons() {
      Set<Polygon> a = {};

      if (hammerIsTaped == true) {
        a.addAll(_polygonSetDisable);
        return a;
      } else {
        a.addAll(_polygonSet);
        return a;
      }
    }

    Map clasification = {
      'm2': null,
      'precio': null,
      'habitaciones': null,
      'baños': null,
      'garage': null
    };

    bool hasClasificationChanged() {
      for (var element in clasification.keys) {
        if (clasification[element] != null) {
          return true;
        }
      }

      return false;
    }

    // int conta=0;
    GoogleMap mapa = GoogleMap(
      myLocationEnabled: false,
      mapType: MapType.normal,
      // zoomControlsEnabled: false,
      // polygons: hammerIsTaped == true ? paintPolygons() : _polygonSet,

      polygons: paintPolygons(),
      onTap: onTap,
      markers: markers,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _customInfoWindowController.googleMapController = controller;

        _controller.complete(controller);
      },
      onCameraMove: (latLngPosition) {
        _customInfoWindowController.onCameraMove!();
      },
    );

    var device_data = MediaQuery.of(context);

    var size = device_data.size;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: device_data.size.width,
                  height: device_data.size.height,
                  child: mapa,
                ),
              ),
              CustomInfoWindow(
                controller: _customInfoWindowController,
                height: 180,
                width: 200,
                offset: 80,
              ),
              Container(
                padding: const EdgeInsets.only(top: 7),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: device_data.size.width * 0.7,
                      child: TextField(
                        focusNode: textFieldFocus,
                        controller: _textLugar,
                        onChanged: (value) {
                          direccion.value = value;
                        },
                        decoration: InputDecoration(
                          hoverColor: Colors.black,
                          labelText: "Ingrese su dirección",
                          labelStyle: const TextStyle(color: Colors.black),
                          border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(style: BorderStyle.none, width: 0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: _textLugar.clear,
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: DesingColors.orange),
                      onPressed: () async {
                        textFieldFocus.unfocus();
                        _markers.clear();
                        _polygonSet.clear();
                        _polygonSetDisable.clear();

                        if (_textLugar.text == '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Escribe o selecciona una zona por favor')));
                        } else {
                          final locations = await getLocation();

                          LatLng latLngPosition = LatLng(
                              locations[0].latitude, locations[0].longitude);

                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                  latLngPosition.latitude,
                                  latLngPosition.longitude);

                          final resultados = await MySQLConnector.getData(
                              placemarks[0].postalCode);

                          for (Map element in resultados[2]) {
                            totalHabitantes.value[0] += int.parse(element['t']);
                            totalHabitantes.value[1] += int.parse(element['m']);
                            totalHabitantes.value[2] += int.parse(element['f']);
                          }

                          var res_data = await MySQLConnector.getMarkersbyCP(
                              placemarks[0].postalCode);

                          setState(() {
                            postalCode = placemarks[0].postalCode;
                          });
                          MarkersCom markerscom = MarkersCom(res_data);
                          // ignore: use_build_context_synchronously
                          final markersComers =
                              // ignore: use_build_context_synchronously
                              await markerscom.printMarkersComers(
                                  _customInfoWindowController,
                                  context,
                                  deviceData);

                          setState(() {
                            print('PINTAR LA ZONA_______________');

                            hasPaintedAZone = true;

                            myPolygon(resultados);

                            postionOnTap = latLngPosition;

                            // hasPaintedAZone = true;
                            // myPolygon(resultados);

                            for (Marker element in markersComers) {
                              _markers[element.markerId] = element;
                            }
                          });
                        }
                      },
                      child: const Icon(
                        Icons.search_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              Builder(builder: (context) {
                if (hasPaintedAZone) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        vertical: size.height * 0.12, horizontal: 10),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.black),
                        onPressed: () async {
                          ///////

                          await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Center(
                                    child: Text('Filtra tu busqueda'),
                                  ),
                                  content: SizedBox(
                                    height: size.height * 0.36,
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Text(
                                              'Rango de precio de los locales:'),
                                          SliderPrice(
                                            rangeValue: (value) {
                                              clasification['precio'] = value;
                                            },
                                          ),
                                          Text('Rango de m3 de los locales:'),
                                          SliderM2(
                                            rangeValue: (value) {
                                              clasification['m2'] = value;
                                            },
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  const Text('Habitaciones'),
                                                  const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5)),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.05,
                                                      width: size.width * 0.18,
                                                      child: TextField(
                                                        onChanged: (value) {
                                                          setState(() {
                                                            clasification[
                                                                    'habitaciones'] =
                                                                value;
                                                          });
                                                        },
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration: const InputDecoration(
                                                            border: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                    width: 1),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5.0)))),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                      ))
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  const Text('Baños'),
                                                  const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5)),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.05,
                                                      width: size.width * 0.18,
                                                      child: TextField(
                                                        onChanged: (value) {
                                                          setState(() {
                                                            clasification[
                                                                    'baños'] =
                                                                value;
                                                          });
                                                        },
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration: const InputDecoration(
                                                            border: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                    width: 1),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5.0)))),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                      ))
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5)),
                                          const Text('Cuartos de garage'),
                                          const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5)),
                                          SizedBox(
                                              height: size.height * 0.05,
                                              width: size.width * 0.18,
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    clasification['garage'] =
                                                        value;
                                                  });
                                                },
                                                textAlign: TextAlign.center,
                                                decoration: const InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.black,
                                                            style: BorderStyle
                                                                .solid,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5.0)))),
                                                keyboardType:
                                                    TextInputType.number,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Center(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Filtrar')),
                                    )
                                  ],
                                );
                              });

                          setState(() {
                            hasChangedFilter = hasClasificationChanged();
                          });
                          // ACTUALIZAR LA LISTA DE MARKERS
                          var res_data =
                              await MySQLConnector.getMarkersbyCP(postalCode);
                          List filteredList =
                              filtiringList(res_data, clasification);

                          MarkersCom markerscom = MarkersCom(filteredList);
                          final markersComers =
                              // ignore: use_build_context_synchronously
                              await markerscom.printMarkersComers(
                                  _customInfoWindowController,
                                  context,
                                  deviceData);
                          setState(() {
                            _markers.clear();

                            for (Marker element in markersComers) {
                              _markers[element.markerId] = element;
                            }
                          });
                        },
                        child: const Icon(Icons.filter_list_rounded)),
                  );
                } else {
                  return const Text('');
                }
              }),
              Builder(
                builder: (context) {
                  if (hasChangedFilter) {
                    return Container(
                      margin: EdgeInsets.symmetric(
                          vertical: size.height * 0.12, horizontal: 10),
                      child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.black),
                          onPressed: () async {
                            var res_data =
                                await MySQLConnector.getMarkersbyCP(postalCode);

                            MarkersCom markerscom = MarkersCom(res_data);
                            // ignore: use_build_context_synchronously
                            final markersComers =
                                // ignore: use_build_context_synchronously
                                await markerscom.printMarkersComers(
                                    _customInfoWindowController,
                                    context,
                                    deviceData);

                            setState(() {
                              for (var element in clasification.keys) {
                                clasification[element] = null;
                              }
                              hasChangedFilter = hasClasificationChanged();

                              // REGRESAR LOS MARKERS NORMALES
                              _markers.clear();

                              for (Marker element in markersComers) {
                                _markers[element.markerId] = element;
                              }
                            });
                          },
                          child: const Icon(Icons.filter_list_off_rounded)),
                    );
                  }
                  return SizedBox();
                },
              ),
              Builder(builder: (context) {
                if (window_visiviliti == true || buttonAE.value == true) {
                  return Container(
                    margin: EdgeInsets.only(
                        top: device_data.size.height - 690,
                        left: device_data.size.width - 65),
                    child: FloatingActionButton(
                      backgroundColor: DesingColors.dark,
                      onPressed: () {
                        Set<Polygon> _polygonSet_auxiliar = new Set();

                        var tam_polygon_Set = _polygonSet.length;
                        var contador = 0;
                        for (var element in _polygonSet) {
                          if (contador < tam_polygon_Set - 1) {
                            _polygonSet_auxiliar.add(element.clone());
                          }
                          contador++;
                        }

                        setState(() {
                          _customInfoWindowController.hideInfoWindow!();
                          _polygonSet.clear();
                          _polygonSet.addAll(_polygonSet_auxiliar);

                          window_visiviliti = false;
                          buttonAE.value = false;
                        });
                      },
                      child:
                          const Icon(Icons.visibility_off, color: Colors.white),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              }),
              Builder(builder: (context) {
                if (count_markers > 0) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        // border: Border.all(width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    width: 70,
                    height: 40,
                    padding: const EdgeInsets.only(top: 5),
                    margin: EdgeInsets.only(
                        top: device_data.size.height - 725,
                        left: device_data.size.width - 80),
                    child: Text(
                      "$count_markers \ncomercios",
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return Container();
                }
              })
            ],
          ),
        ),
        floatingActionButton: Container(
          width: device_data.size.width - 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                backgroundColor: DesingColors.dark,
                onPressed: () {
                  print('RANGO DE PRECIOOOOOOOOOOOOOOO');
                  print(clasification['precio']);
                  _polygonSet.clear();
                  _textLugar.clear();
                  totalHabitantes.value[0] = 0;
                  totalHabitantes.value[1] = 0;
                  totalHabitantes.value[2] = 0;

                  setState(() {
                    _customInfoWindowController.hideInfoWindow!();
                    window_visiviliti = false;
                    _markers.clear();
                    hasPaintedAZone = false;
                    hammerIsTaped = false;
                    _textActividadEconomica.clear();
                    actividadEconomica.value = '';
                    buttonDisable.value = true;
                    count_markers = 0;
                  });
                },
                child: const Icon(Icons.delete_rounded),
              ),
              SizedBox(
                width: device_data.size.width * 0.6,
              ),
              Builder(
                builder: (context) {
                  if (hasPaintedAZone == false) {
                    return FloatingActionButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Escribe o selecciona una zona por favor'),
                          ),
                        );
                      },
                      backgroundColor: DesingColors.bottonDisable,
                      child: const Icon(Icons.do_disturb_alt_outlined),
                    );
                  } else {
                    return SpeedDial(
                      overlayOpacity: 0,
                      renderOverlay: false,
                      backgroundColor: DesingColors.dark,
                      animatedIcon: AnimatedIcons.menu_close,
                      spaceBetweenChildren: 10,
                      children: [
                        SpeedDialChild(
                            backgroundColor: DesingColors.orange,
                            onTap: () {
                              setState(
                                () {
                                  if (hammerIsTaped) {
                                    _markers
                                        .remove(const MarkerId('hammerMaker'));
                                  }
                                  hammerIsTaped = !hammerIsTaped;
                                },
                              );
                            },
                            child: const Icon(
                              Icons.gavel_rounded,
                              color: Colors.white,
                            )),
                        SpeedDialChild(
                          backgroundColor: DesingColors.yellow,
                          child: const Icon(Icons.local_police_rounded),
                        ),
                        SpeedDialChild(
                          backgroundColor: DesingColors.yellow,
                          child: const Icon(Icons.analytics_rounded),
                          onTap: () async {
                            final otherDemografic =
                                await MySQLConnector.getDemograficData();
                            showDialog(
                                context: context,
                                builder: (context) => DemograficModal(
                                    totalHabitantes.value[0],
                                    totalHabitantes.value[1],
                                    totalHabitantes.value[2],
                                    otherDemografic));
                          },
                        ),
                        SpeedDialChild(
                            backgroundColor: DesingColors.orange,
                            child: const Icon(
                              Icons.storefront,
                              color: Colors.white,
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => StatefulBuilder(builder:
                                          (context, StateSetter setState) {
                                        return AlertDialog(
                                          title: const Center(
                                              child: Text(
                                            'Escribe tu actividad economica',
                                            style: TextStyle(fontSize: 18),
                                          )),
                                          content: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: TextField(
                                                focusNode:
                                                    textFieldFocus_actividad,
                                                decoration: InputDecoration(
                                                    suffixIcon: Container(
                                                      color:
                                                          DesingColors.orange,
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          var isEconomyActivity =
                                                              await datosDenue
                                                                  .isEconomyActivity(
                                                                      actividadEconomica
                                                                          .value);

                                                          if (isEconomyActivity) {
                                                            textFieldFocus_actividad
                                                                .unfocus();

                                                            buttonDisable
                                                                .value = false;
                                                            print(buttonDisable
                                                                .value);
                                                          } else {
                                                            buttonDisable
                                                                .value = true;
                                                          }
                                                          setState(
                                                            () {},
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.search_rounded,
                                                          color:
                                                              DesingColors.dark,
                                                        ),
                                                      ),
                                                    ),
                                                    errorText: actividadEconomica
                                                                    .value !=
                                                                '' &&
                                                            buttonDisable
                                                                    .value ==
                                                                true
                                                        ? 'Escribe una actividad economica valida por favor'
                                                        : null,
                                                    hintText:
                                                        'Ejemplo: Abarrotes'),
                                                controller:
                                                    _textActividadEconomica,
                                                onChanged: (value) {
                                                  actividadEconomica.value =
                                                      value;
                                                }),
                                          ),
                                          actions: [
                                            Center(
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary: DesingColors
                                                              .dark),
                                                  onPressed:
                                                      buttonDisable.value ==
                                                              true
                                                          ? null
                                                          : () async {
                                                              final icon =
                                                                  await BitmapDescriptor
                                                                      .fromAssetImage(
                                                                const ImageConfiguration(),
                                                                'lib/_img/marcador_denue_chico.png',
                                                              );
                                                              int cont = 0;
                                                              List<Map> list = await datosDenue.fetchPost(
                                                                  actividadEconomica
                                                                      .value,
                                                                  postionOnTap!
                                                                      .latitude
                                                                      .toString(),
                                                                  postionOnTap!
                                                                      .longitude
                                                                      .toString());
                                                              //CODE GOOGLE PLACES ................................
                                                              List<Map> lista_places = await GooglePlace.get_places_all(
                                                                  actividadEconomica
                                                                      .value,
                                                                  postionOnTap!
                                                                      .latitude
                                                                      .toString(),
                                                                  postionOnTap!
                                                                      .longitude
                                                                      .toString());
                                                              int contador_places =
                                                                  0;

                                                              for (var element
                                                                  in lista_places) {
                                                                String id =
                                                                    "Place $contador_places";
                                                                Marker
                                                                    marker_place =
                                                                    await GooglePlace
                                                                        .marker_window_places(
                                                                  id,
                                                                  LatLng(
                                                                    element[
                                                                        "lat"],
                                                                    element[
                                                                        "lon"],
                                                                  ),
                                                                  element[
                                                                      "nombre"],
                                                                  _customInfoWindowController,
                                                                );

                                                                _markers[marker_place
                                                                        .markerId] =
                                                                    marker_place;
                                                                contador_places++;
                                                              }

                                                              for (var element
                                                                  in list) {
                                                                String name =
                                                                    element[
                                                                        'nombre'];
                                                                String descrip =
                                                                    element[
                                                                        'descripcion'];

                                                                double lat =
                                                                    double.parse(
                                                                        element[
                                                                            'lat']);

                                                                double lon =
                                                                    double.parse(
                                                                        element[
                                                                            'lon']);

                                                                LatLng
                                                                    position =
                                                                    LatLng(lat,
                                                                        lon);

                                                                var markerId =
                                                                    MarkerId(
                                                                        'rivals$cont');
                                                                cont++;
                                                                final marker =
                                                                    Marker(
                                                                  icon: icon,
                                                                  markerId:
                                                                      markerId,
                                                                  position:
                                                                      position,
                                                                  zIndex: 2,
                                                                  anchor:
                                                                      const Offset(
                                                                          0.5,
                                                                          1),
                                                                  onTap: () {
                                                                    buttonAE.value =
                                                                        true;

                                                                    _customInfoWindowController
                                                                            .addInfoWindow!(
                                                                        Container(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 15),
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(10)),
                                                                            color:
                                                                                DesingColors.nuse,
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Center(
                                                                                  child: Text(
                                                                                name,
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(fontSize: 15, color: Colors.white),
                                                                              )),
                                                                              const Divider(
                                                                                color: Colors.white,
                                                                                thickness: 2,
                                                                              ),
                                                                              Text('$descrip.',
                                                                                  style: const TextStyle(
                                                                                    fontSize: 13,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  textAlign: TextAlign.justify),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        position);
                                                                    update();
                                                                  },
                                                                  draggable:
                                                                      false,
                                                                );

                                                                setState(() {
                                                                  _markers[
                                                                          markerId] =
                                                                      marker;
                                                                  count_markers =
                                                                      _markers
                                                                          .length;
                                                                });
                                                              }
                                                              // ignore: use_build_context_synchronously
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                  child:
                                                      const Text('Siguiente')),
                                            ),
                                          ],
                                        );
                                      }));
                            }),
                      ],
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Set<Polygon> myPolygon(
    List listaGeometry,
  ) {
    int conta = 0;
    var aux;

    List hola = [];

    for (var i = 0; i < listaGeometry[1].length; i++) {
      List<LatLng> polygonCoords =
          polygonsMetods().geometry_data(listaGeometry[1][i]);
      hola.add(conta);

      Polygon po = Polygon(
        geodesic: true,
        polygonId: PolygonId(listaGeometry[0][i]),
        points: polygonCoords,
        consumeTapEvents: true,
        zIndex: -1,
        strokeColor: ColorPolygon.borderColor,
        strokeWidth: 5,
        fillColor: ColorPolygon.filling,
        onTap: () async {
          _customInfoWindowController.addInfoWindow!(
              window_map(
                data: listaGeometry[2][i],
                listaPolygons: _polygonSet,
              ),
              polygonCoords[0]);

          setState(
            () {
              window_visiviliti = true;
              polygon_seleccion(listaGeometry[0][i]);

              bool bandera = false;
              Set<Polygon> temporalListaPolygons2 = new Set();
              var contador = 0;

              if (_polygonSet.last.polygonId == const PolygonId("seleccion")) {
                for (var element in _polygonSet) {
                  if (contador < _polygonSet.length - 1) {
                    temporalListaPolygons2.add(element.clone());
                  }
                  contador++;
                }
                _polygonSet.clear();
                _polygonSet.addAll(temporalListaPolygons2);
              }
            },
          );
        },
      );

      Polygon po2 = Polygon(
        geodesic: true,
        polygonId: PolygonId('test $conta'),
        points: polygonCoords,
        consumeTapEvents: false,
        zIndex: -1,
        strokeColor: ColorPolygon.borderColor2,
        strokeWidth: 5,
        fillColor: ColorPolygon.filling2,
      );

      _polygonSetDisable.add(po2);
      _polygonSet.add(po);

      conta = conta + 1;
    }

    return _polygonSet;
  }

  void polygon_seleccion(ageb) async {
    final resultados = await MySQLConnector.getPolygonBYageb(ageb);
    print(resultados);
    List<LatLng> polygonCoords_2 =
        polygonsMetods().geometry_data(resultados[0]);

    Polygon po = Polygon(
      geodesic: true,
      polygonId: const PolygonId("seleccion"),
      points: polygonCoords_2,
      consumeTapEvents: true,
      zIndex: -1,
      strokeColor: ColorPolygon.filling,
      strokeWidth: 5,
      fillColor: ColorPolygon.borderColor,
    );

    setState(
      () {
        _polygonSet.add(po);
      },
    );
  }

  void update() {
    setState(() {});
  }

  List filtiringList(List res_data, Map clasification) {
    List listFiltered = [];

    //   Map clasification = {
    //   'm2': null,
    //   'precio': null,
    //   'habitaciones': null,
    //   'baños': null,
    //   'garage': null
    // };

    for (var i = 0; i < res_data.length; i++) {
      int goTofilter = 0;

      var place = res_data[i];
      // print(place['nombre']);
      // print(place['precio']);
      if (clasification['m2'] != null && goTofilter != 2) {
        RangeValues rangeM2 = clasification['m2'];
        // print('verificando m3...');

        if (double.parse(place['superficie_m3']) >= rangeM2.start &&
            double.parse(place['superficie_m3']) <= rangeM2.end) {
          goTofilter = 1;
        } else {
          goTofilter = 2;
        }
      }
      if (clasification['precio'] != null && goTofilter != 2) {
        // print('verificando precio...');

        RangeValues rangePrice = clasification['precio'];
        // print('Rango del filtro: ${rangePrice}');

        if (double.parse(place['precio']) >= rangePrice.start &&
            double.parse(place['precio']) <= rangePrice.end) {
          goTofilter = 1;
        } else {
          goTofilter = 2;
        }
      }
      if (clasification['habitaciones'] != null && goTofilter != 2) {
        // print('verificando habitaciones...');
        if (clasification['habitaciones'] == place['num_cuartos']) {
          goTofilter = 1;
        } else {
          goTofilter = 2;
        }
      }
      if (clasification['baños'] != null && goTofilter != 2) {
        // print('verificando baños...');

        if (clasification['baños'] == place['num_baños']) {
          goTofilter = 1;
        } else {
          goTofilter = 2;
        }
      }
      if (clasification['garage'] != null && goTofilter != 2) {
        print('verificando garage...');

        if (clasification['garage'] == place['num_cajones']) {
          goTofilter = 1;
        } else {
          goTofilter = 2;
        }
      }

      if (goTofilter == 1) {
        listFiltered.add(place);
      }
    }
    // print('LO FILTRADOOOOO');
    // print(listFiltered.length);
    // listFiltered.forEach((element) {
    // print(element['nombre']);
    // print(element['precio']);
    // });
    return listFiltered;
  }
}
