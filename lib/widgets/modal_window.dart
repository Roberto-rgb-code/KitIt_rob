import 'package:flutter/material.dart';

import '../service/datos_predios.dart';

class modal_window {
   late BuildContext context;
  late double size_word;
  modal_window(BuildContext context, double size_word) {
    this.context = context;
    this.size_word = size_word;
  }

   void modal2(String nombreNegocio, String descripcion) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Expanded(child: Container(color: Colors.amber,));
        });
  }

  dynamic venta_modal_error() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: 600,
          child: Center(
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding:
                          const EdgeInsetsDirectional.only(bottom: 10, top: 10),
                      child: const Text(
                        "No se encontraron datos",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  dynamic venta_modal_info(value, device_data, bandera_window) {
    List<Widget> usos_permitidos_list = [];
    List<Widget> usos_no_permitidos_list = [];
    String inStringCus = "";
    double inDoubleCus = 0;
    if (bandera_window == true) {
      inStringCus = value[0]["cus"].toStringAsFixed(2); // '2.35'
      inDoubleCus = double.parse(inStringCus);

      var usos_permitidos = value[0]["zonificacion_default"]["usos_permitidos"];
      var usos_no_permitidos =
          value[0]["zonificacion_default"]["usos_condicionados"];

      for (var tipo_uso in usos_permitidos) {
        String? tipo_uso_string = tipos_uso_nombre[tipo_uso];
        var texto = Container(
          padding: const EdgeInsetsDirectional.only(start: 10, top: 5),
          height: 30,
          width: device_data.size.width - 50,
          color: const Color(0xff39B339),
          child: Text(
            "$tipo_uso - ${tipo_uso_string!}",
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.left,
          ),
        );

        usos_permitidos_list.add(texto);
      }

      for (var tipo_uso_no in usos_no_permitidos) {
        String? tipo_uso_no_string = tipos_uso_nombre[tipo_uso_no];
        var texto = Container(
          padding:
              const EdgeInsetsDirectional.only(start: 10, top: 5, bottom: 10),
          height: 30,
          width: device_data.size.width - 50,
          color: const Color(0xff39B339),
          child: Text(
            tipo_uso_no + " - " + tipo_uso_no_string!,
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.left,
          ),
        );

        usos_no_permitidos_list.add(texto);
      }
    }

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            height: 600,
            child: Center(
              child: bandera_window
                  ? ListView(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsetsDirectional.only(
                                  bottom: 10, top: 10),
                              child: const Text(
                                "Datos del lugar",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            info_total("Clave Catastral: ${value[0]["clave"]}"),
                            info_total("Tipo: ${value[0]["tipo"]}"),
                            info_total("Ubicacion:  ${value[0]["ubicacion"]}"),
                            info_total("Colonia: ${value[0]["colonia"]}"),
                            info_total("Clave Catastral: ${value[0]["clave"]}"),
                            info_total(
                                "Superficie de Terreno: Escritura ${value[0]["superficieLegal"].toString()} m2"),
                            info_total(
                                "Superficie de Terreno: Cartografía ${value[0]["superficieCarto"].toStringAsFixed(2)} m2"),
                            info_total(
                                "Superficie Construida: ${value[0]["superficieConstruccion"].toString()} m2"),
                            info_total(
                                "Frente de Predio: ${value[0]["frente"].toString()} m"),
                            info_total(
                                "Zonificacion: ${value[0]["clave"].toString()}"),
                            info_total(
                                "COS: ${value[0]["cos"].toStringAsFixed(2)}"),
                            info_total(
                                "COS:  ${value[0]["zonificacion_default"]["cos"].toString()} 0"),
                            info_total("CUS: ${inDoubleCus.toString()}"),
                            info_total(
                                "CUS permitido:  ${value[0]["zonificacion_default"]["cus_max"].toString()}"),
                          ],
                        ),
                        const Divider(),
                        Container(
                          padding: const EdgeInsetsDirectional.only(bottom: 10),
                          child: const Text(
                            'Usos Permitidos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Column(
                            children: usos_permitidos_list,
                            mainAxisAlignment: MainAxisAlignment.spaceAround),
                        const Divider(),
                        Container(
                          padding: const EdgeInsetsDirectional.only(bottom: 10),
                          child: const Text(
                            'Usos Condicionados',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Column(children: usos_no_permitidos_list),
                        const Divider()
                      ],
                    )
                  : ListView(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsetsDirectional.only(
                                  bottom: 10, top: 10),
                              child: const Text(
                                "No se encontraron datos",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
            ));
      },
    );
  }

  Widget info_total(data) {
    return Container(
      padding: const EdgeInsetsDirectional.only(bottom: 5),
      child: Text(
        data,
        style: TextStyle(fontSize: size_word),
      ),
    );
  }
}
