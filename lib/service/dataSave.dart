import 'package:shared_preferences/shared_preferences.dart';

class DataSave {
  static void setInicio() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('entro', true).then((value) => {});
  }

  static Future<bool?> getInicio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entro = prefs.getBool('entro');
      return entro;
    } catch (e) {
      // print(e);
    }

    // print(entro);
  }
}
