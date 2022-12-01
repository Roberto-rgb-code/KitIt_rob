import 'dart:convert';
import 'package:http/http.dart' as http;

class datosDenue {
  static Future<List<Map>> fetchPost(
      tipoComercio, String latitud, String longitud) async {
    var response = await http.get(Uri.parse(
        'https://www.inegi.org.mx/app/api/denue/v1/consulta/Buscar/${tipoComercio}/${latitud},${longitud}/1500/d28a2536-ca8d-47da-bfac-6a57d5c396e0'));

    if (response.statusCode == 200) {
      List<Map> negocios = [];

      var data = json.decode(response.body);
      for (var element in data) {
        negocios.add({
          'lat':element["Latitud"],
          'lon':element["Longitud"],
          'nombre':element["Nombre"],
          'descripcion':element["Clase_actividad"]
        });
      }
      return negocios;
    } else {
      throw Exception('Failed to load post');
    }
  }

  static Future<bool> isEconomyActivity(String economyA) async {
    print('Probamos si la ACTIVIDAD ECONOMICA JALA');
    var response = await http.get(Uri.parse(
        'https://www.inegi.org.mx/app/api/denue/v1/consulta/BuscarEntidad/$economyA/14/1/1/319c3103-92db-49e2-9512-0ee285fe3ba9'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      print('Si LLEGO ALGO');
      return true;
    }
    if (response.statusCode == 404) {
      print('NO LLEGO NADA');
      return false;
    } else {
      throw Exception('Failed to load post');
    }
  }
}
