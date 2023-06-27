import 'package:agilapp/alimentacion.dart';
import 'package:agilapp/estadisticalimento.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class sql {
  static DateTime startDate = DateTime.now();
  static DateTime endDate = DateTime.now();
  static String nombreuser = '';
  static String correouser = '';
  static List<DateTime> miArrayGlobal = [];
  sql();
  sql.obtenerfecha(DateTime fechaIni, DateTime fechaFin) {
    miArrayGlobal.add(fechaIni);
    miArrayGlobal.add(fechaFin);
    startDate = fechaIni;
    endDate = fechaFin;
  }

  final settings = ConnectionSettings(
    host: 'bdmaqgeqcojjnmapceth-mysql.services.clever-cloud.com',
    port: 3306,
    user: 'ufaomtpab6ngtxtl',
    password: 'ouVHL4pCZexLZWKJu1fT',
    db: 'bdmaqgeqcojjnmapceth',
  );

  Future<bool> insertarRegistro(
      String correo,
      String nombres,
      String nombres2,
      String apellidos,
      String apellidos2,
      int estatura,
      int peso,
      String contrasenia,
      DateTime fecha,
      BuildContext context) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      final conn = await MySqlConnection.connect(settings);

      print('Conexión exitosa');

      final result = await conn.query(
          'INSERT INTO USUARIOS (COR_ELE, NOM_PER, NOM2_PER, APE_PER, APE2_PER, EST_PER, PES_PER, CON_USU , FEC_NAC) VALUES (?, ?, ?, ?, ?, ?, ?, ?,?)',
          [
            correo,
            nombres,
            nombres2,
            apellidos,
            apellidos2,
            estatura,
            peso,
            contrasenia,
            fecha
          ]);

      int n = result.affectedRows!.toInt();
      if (n > 0) {
        await conn.close();
        return true;
      } else {
        await conn.close();
        return false;
      }
    } catch (e) {
      if (e is MySqlException && e.errorNumber == 1062) {
        // Clave primaria duplicada
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error al crear el usuario '),
              content: Text('El usuario ya existe '),
              actions: <Widget>[
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Otras excepciones
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de conexión'),
              content: Text(
                'Hubo un problema al conectarse a la base de datos. Por favor, inténtalo de nuevo más tarde. \n $e',
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      return false;
    }
  }

  Future<bool> obtenerUsuarioYContrasenia(
      String contrasenia, String corEle, BuildContext context) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      final conn = await MySqlConnection.connect(settings);
      var result = await conn.query(
        'SELECT COR_ELE, CON_USU ,NOM_PER FROM USUARIOS WHERE CON_USU = ? AND COR_ELE = ?',
        [contrasenia, corEle],
      );

      if (result.isNotEmpty) {
        for (var row in result) {
          var correoElectronico = row['COR_ELE'];
          var contraseniaUser = row['CON_USU'];
          nombreuser = row['NOM_PER'];
          correouser = correoElectronico;
          if (contrasenia == contraseniaUser && corEle == correoElectronico) {
            correouser = correoElectronico;
            await conn.close();
            return true;
          }
        }

        await conn.close();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Advertencia'),
              content: Text(
                  'Credenciales incorrectas. Por favor, inténtalo de nuevo.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return false;
      } else {
        await conn.close();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Advertencia'),
              content: Text(
                  'Credenciales incorrectas. Por favor, inténtalo de nuevo.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return false;
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de conexión'),
            content: const Text(
                'Hubo un problema al conectarse a la base de datos. Por favor, inténtalo de nuevo más tarde.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }
  }

  late SharedPreferences prefs;
  late String email = '';
  late String contrasenna = '';
  late bool isLoggedIn = false;
  Future<bool> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      email = prefs.getString('email') ?? '';
      contrasenna = prefs.getString('contraseña') ?? '';
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    } else {
      email = ''; // Valor predeterminado
      isLoggedIn = false; // Valor predeterminado
      contrasenna = '';
    }
    return isLoggedIn;
  }

  Future<bool> obtenerInfo() async {
    WidgetsFlutterBinding.ensureInitialized();
    initializePreferences();

    try {
      final conn = await MySqlConnection.connect(settings);
      var result = await conn.query(
        'SELECT COR_ELE, CON_USU ,NOM_PER FROM USUARIOS WHERE CON_USU = ? AND COR_ELE = ?',
        [contrasenna, email],
      );

      if (result.isNotEmpty) {
        for (var row in result) {
          var correoElectronico = row['COR_ELE'];
          var contraseniaUser = row['CON_USU'];
          nombreuser = row['NOM_PER'];
          correouser = correoElectronico;
          if (contrasenna == contraseniaUser && email == correoElectronico) {
            correouser = correoElectronico;
            await conn.close();
            return true;
          }
        }

        await conn.close();

        return false;
      } else {
        await conn.close();

        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> obtenertipo() async {
    List<String> listaAlimentos = [];

    try {
      final conn = await MySqlConnection.connect(settings);
      var result = await conn.query('SELECT NOM_ALI FROM TIPO_ALIMENTO');

      if (result.isNotEmpty) {
        for (var row in result) {
          var nombreAlimento = row['NOM_ALI'] as String;
          listaAlimentos.add(nombreAlimento);
        }
        await conn.close();
      }

      await conn.close();
    } catch (e) {}

    return listaAlimentos;
  }

  Future<List<String>> obtenerAlimento(String tipo) async {
    List<String> listaAlimentos = [];

    try {
      final conn = await MySqlConnection.connect(settings);
      var result = await conn.query(
          'SELECT NOM_ALI FROM ALIMENTOS WHERE TIP_ALI = (SELECT ID_TIP FROM TIPO_ALIMENTO WHERE NOM_ALI = ?)',
          [tipo]);

      if (result.isNotEmpty) {
        for (var row in result) {
          var nombreAlimento = row['NOM_ALI'] as String;
          listaAlimentos.add(nombreAlimento);
        }
        await conn.close();
      }

      await conn.close();
    } catch (e) {
      // Manejo de excepciones
    }

    return listaAlimentos;
  }

  Future<bool> insertarAlimento(String alimento) async {
    initializePreferences();

    try {
      final conn = await MySqlConnection.connect(settings);

      var result = await conn.query(
        'SELECT ID_ALI FROM ALIMENTOS WHERE  NOM_ALI = ?',
        [alimento],
      );

      if (result.isNotEmpty) {
        for (var row in result) {
          var id = row['ID_ALI'] as int;

          var now = DateTime.now();
          var formattedDate =
              DateFormat('yyyy-MM-dd').format(now); // Formatea la fecha actual

          await conn.query(
            'INSERT INTO DETALLE_ALIMENTOS (COR_ELE, ID_ALI, FEC_ALI) VALUES (?, ?, ?)',
            [
              email,
              id,
              formattedDate,
            ],
          );
        }
        return true;
      }
      await conn.close();
      return false;
    } catch (e) {
      print('Error al insertar alimento: $e');
      print("Error de correo vacío");
      print(email);
      return false;
    }
  }

  Future<List<Expenses>> obtenerAlimentoCalorias() async {
    initializePreferences();
    List<Expenses> data = [];
    print(startDate);
    print(endDate);
    try {
      final conn = await MySqlConnection.connect(settings);
      var result = await conn.query(
          'SELECT ALIMENTOS.NOM_ALI, ALIMENTOS.CAL_ALI FROM ALIMENTOS INNER JOIN DETALLE_ALIMENTOS ON ALIMENTOS.ID_ALI = DETALLE_ALIMENTOS.ID_ALI WHERE DETALLE_ALIMENTOS.COR_ELE = ? AND DETALLE_ALIMENTOS.FEC_ALI BETWEEN ? AND ?',
          [email, startDate, endDate]);

      if (result.isNotEmpty) {
        print("Se obtienen datos");
        for (var row in result) {
          var nombreAlimento = row['NOM_ALI'];
          var caloriasAlimento = row['CAL_ALI'];
          data.add(Expenses(nombreAlimento, caloriasAlimento));
        }
        await conn.close();
        return data; // Agregar retorno aquí
      }

      await conn.close();
    } catch (e) {
      print("No conextado");
    }

    return data;
  }
}
