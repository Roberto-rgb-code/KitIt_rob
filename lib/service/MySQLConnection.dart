import 'package:mysql_client/mysql_client.dart';

class MySQLConnector {
  // static final _settings = MySQLConnection(
  //   host: '192.168.100.226',
  //   port: 3306,
  //   userName: 'kikit2',
  //   password: 'polloasado1',
  //   databaseName: 'kikit',
  // );

  static late MySQLConnection connector;

  MySQLConnector() {
    connection();
  }

  static void connection() async {
    connector = await MySQLConnection.createConnection(
      host: "192.168.100.247",
      port: 3306,
      userName: "kikit2",
      password: "polloasado1",
      databaseName: "kikit", // optional
    );
    print('CONENCTANDO A BASE DE DATOS');
    await connector.connect();
    print(
        'Conexión exitosa a la base de datos____________________________________________________');
  }

  static void prueba() {
    print('ESTA CONECTADOOOOOOOOOOOO????');
    print(connector.connected);
  }

  static Future<List> getData(CP) async {
    List geometry_list = [];
    List demografic_data = [];
    List agebs = [];
    print('____________________________________CODIGO POSTAL ${CP}');
    var result = await connector.execute(
        // "SELECT * FROM agebs where region=5 ",
        "select * from agebs  where agebs.codigoPostal= :CP",
        {'CP': CP});

    print('______RESULTADOS_______');

    for (final row in result.rows) {
      // print(row.assoc());

      geometry_list.add([row.assoc()["geometry"]]);
      agebs.add(row.assoc()["idAgeb"]);
      // row.assoc()["numTotalFemenino"],
      //   row.assoc()["numTotalMasculino"],
      //   row.assoc()["numTotalHabitantes"]

      Map map = {
        'f': row.assoc()["numTotalFemenino"],
        'm': row.assoc()["numTotalMasculino"],
        't': row.assoc()["numTotalHabitantes"],
      };
      demografic_data.add(map);
    }
    // print(agebs);
    // print(demografic_data);
    return [agebs, geometry_list, demografic_data];
  }

  static Future<List> getPolygonBYageb(ageb) async {
    List geometry_list = [];
    var result = await connector.execute(
        // "SELECT * FROM agebs where region=5 ",
        "select * from agebs  where agebs.idAgeb= :idAgeb",
        {'idAgeb': ageb});

    for (final row in result.rows) {
      // print(row.assoc());

      geometry_list.add([row.assoc()["geometry"]]);
    }
    return geometry_list;
  }
}
