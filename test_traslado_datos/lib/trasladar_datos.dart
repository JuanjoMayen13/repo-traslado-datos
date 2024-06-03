import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TrasladarDatosScreen extends StatefulWidget {
  @override
  _TrasladarDatosScreenState createState() => _TrasladarDatosScreenState();
}

class _TrasladarDatosScreenState extends State<TrasladarDatosScreen> {
  // ignore: unused_field
  bool _expandir = false;
  PlatformFile? _archivoSeleccionado;
  String? _tablaSeleccionada;
  Dio _dio = Dio();
  List<String> _nombresHojas = [];
  String? _nombreHojaSeleccionada;

  @override
  void initState() {
    super.initState();
  }

  void _msgSeleccionarTablaSQL() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text('Input vacío', style: TextStyle(color: Colors.red)),
            ],
          ),
          content:
              Text('Por favor, seleccione antes el nombre de una tabla SQL.'),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _msgPosiblesInconvenientes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Inconveniente',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF154790),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Posibles inconvenientes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF154790),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '  Hoja Excel seleccionada incorrecta\n  Archivo Excel Incorrecto',
                  style: TextStyle(color: Color(0xFF154790)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC9525),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _msgSeleccionarArchivo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF154790),
            ),
          ),
          content: Text(
            'No se ha seleccionado un archivo',
            style: TextStyle(color: Color(0xFF154790)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF154790),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _msgInsertadoCorrectamente() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Datos insertados correctamente',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF154790),
              ),
            ),
            content: Text(
              'Datos insertados correctamente en la tabla de la base de datos',
              style: TextStyle(color: Color(0xFF154790)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF154790),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );
    if (result != null) {
      setState(() {
        _archivoSeleccionado = result.files.firstOrNull;
      });
      _obtenerHojasExcel(_archivoSeleccionado!);
    }
  }

  void _obtenerHojasExcel(PlatformFile file) async {
    try {
      // ignore: unnecessary_null_comparison
      if (file != null) {
        FormData formData = FormData.fromMap({
          'archivoExcel':
              await MultipartFile.fromFile(file.path!, filename: file.name),
        });
        final response = await _dio.post(
          'http://192.168.1.20:9091/api/Ctrl_ObtenerHojasExcel',
          data: formData,
        );
        print('Respuesta del servidor: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.data}');
        // Almacenar las hojas en la lista _sheetNames
        setState(() {
          _nombresHojas = List<String>.from(response.data);
        });
      }
    } catch (e) {
      print('Error al enviar el archivo al servidor: $e');
    }
  }

  Future<void> _insertBodega() async {
    try {
      PlatformFile? selectedFile = _archivoSeleccionado;

      if (selectedFile == null) {
        _msgSeleccionarArchivo();
        return;
      }

      FormData formData = FormData.fromMap({
        'ArchivoExcel': await MultipartFile.fromFile(
          selectedFile.path!,
          filename: selectedFile.name,
        ),
        'NombreHojaExcel': _nombreHojaSeleccionada,
        'userName': 'ds'
      });

      final response = await _dio.post(
        'http://192.168.1.20:9091/api/Ctrl_PaExternalBodega',
        data: formData,
      );

      if (response.statusCode == 200) {
        print(
            'Datos insertados correctamente en la tabla de la base de datos.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrasladarDatosScreen()),
        );
        _msgInsertadoCorrectamente();
      } else {
        print('Error en la solicitud al servidor: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF154790),
                ),
              ),
              content: Text(
                'Hubo un error al insertar los datos en la base de datos',
                style: TextStyle(color: Color(0xFF154790)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF154790),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al insertar los datos: $e');
      _msgPosiblesInconvenientes();
    }
  }

  Future<void> _insertClaseProducto() async {
    try {
      PlatformFile? selectedFile = _archivoSeleccionado;
      if (selectedFile == null) {
        _msgSeleccionarArchivo();
        return;
      }

      FormData formData = FormData.fromMap({
        'ArchivoExcel': await MultipartFile.fromFile(
          selectedFile.path!,
          filename: selectedFile.name,
        ),
        'NombreHojaExcel': _nombreHojaSeleccionada,
        'userName': 'ds'
      });

      final response = await _dio.post(
        'http://192.168.1.20:9091/api/Ctrl_PaExternalClaseProducto',
        data: formData,
      );
      if (response.statusCode == 200) {
        print(
            'Datos insertados correctamente en la tabla de la base de datos.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrasladarDatosScreen()),
        );
        _msgInsertadoCorrectamente();
      } else {
        print('Error en la solicitud al servidor: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF154790),
                ),
              ),
              content: Text(
                'Hubo un error al insertar los datos en la base de datos',
                style: TextStyle(color: Color(0xFF154790)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF154790),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al insertar los datos: $e');
      _msgPosiblesInconvenientes();
    }
  }

  Future<void> _insertMarca() async {
    try {
      PlatformFile? selectedFile = _archivoSeleccionado;
      if (selectedFile == null) {
        _msgSeleccionarArchivo();
        return;
      }

      FormData formData = FormData.fromMap({
        'ArchivoExcel': await MultipartFile.fromFile(
          selectedFile.path!,
          filename: selectedFile.name,
        ),
        'NombreHojaExcel': _nombreHojaSeleccionada,
        'userName': 'ds'
      });

      final response = await _dio.post(
        'http://192.168.1.20:9091/api/Ctrl_PaExternalMarca',
        data: formData,
      );

      if (response.statusCode == 200) {
        print(
            'Datos insertados correctamente en la tabla de la base de datos.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrasladarDatosScreen()),
        );
        _msgInsertadoCorrectamente();
      } else {
        print('Error en la solicitud al servidor: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF154790),
                ),
              ),
              content: Text(
                'Hubo un error al insertar los datos en la base de datos',
                style: TextStyle(color: Color(0xFF154790)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF154790),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al insertar los datos: $e');
      _msgPosiblesInconvenientes();
    }
  }

  Future<void> _insertProducto() async {
    try {
      PlatformFile? selectedFile = _archivoSeleccionado;
      if (selectedFile == null) {
        _msgSeleccionarArchivo();
        return;
      }
      FormData formData = FormData.fromMap({
        'ArchivoExcel': await MultipartFile.fromFile(
          selectedFile.path!,
          filename: selectedFile.name,
        ),
        'NombreHojaExcel': _nombreHojaSeleccionada,
        'userName': 'ds'
      });
      final response = await _dio.post(
        'http://192.168.1.20:9091/api/Ctrl_PaExternalProducto',
        data: formData,
      );
      if (response.statusCode == 200) {
        print(
            'Datos insertados correctamente en la tabla de la base de datos.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrasladarDatosScreen()),
        );
        _msgInsertadoCorrectamente();
      } else {
        print('Error en la solicitud al servidor: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF154790),
                ),
              ),
              content: Text(
                'Hubo un error al insertar los datos en la base de datos',
                style: TextStyle(color: Color(0xFF154790)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF154790),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al insertar los datos: $e');
      _msgPosiblesInconvenientes();
    }
  }

  Future<void> _insertTipoPrecio() async {
    try {
      PlatformFile? selectedFile = _archivoSeleccionado;

      if (selectedFile == null) {
        _msgSeleccionarArchivo();
        return;
      }

      FormData formData = FormData.fromMap({
        'ArchivoExcel': await MultipartFile.fromFile(
          selectedFile.path!,
          filename: selectedFile.name,
        ),
        'NombreHojaExcel': _nombreHojaSeleccionada,
        'userName': 'ds'
      });

      final response = await _dio.post(
        'http://192.168.1.20:9091/api/Ctrl_PaExternalTipoPrecio',
        data: formData,
      );

      if (response.statusCode == 200) {
        print(
            'Datos insertados correctamente en la tabla de la base de datos.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrasladarDatosScreen()),
        );
        _msgInsertadoCorrectamente();
      } else {
        print('Error en la solicitud al servidor: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF154790),
                ),
              ),
              content: Text(
                'Hubo un error al insertar los datos en la base de datos',
                style: TextStyle(color: Color(0xFF154790)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF154790),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al insertar los datos: $e');
      _msgPosiblesInconvenientes();
    }
  }

  Future<void> _insertUnidadMedida() async {
    try {
      PlatformFile? selectedFile = _archivoSeleccionado;

      if (selectedFile == null) {
        _msgSeleccionarArchivo();
        return;
      }

      FormData formData = FormData.fromMap({
        'ArchivoExcel': await MultipartFile.fromFile(
          selectedFile.path!,
          filename: selectedFile.name,
        ),
        'NombreHojaExcel': _nombreHojaSeleccionada,
        'userName': 'ds'
      });

      final response = await _dio.post(
        'http://192.168.1.20:9091/api/Ctrl_PaExternalUnidadMedida',
        data: formData,
      );

      if (response.statusCode == 200) {
        print(
            'Datos insertados correctamente en la tabla de la base de datos.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrasladarDatosScreen()),
        );
        _msgInsertadoCorrectamente();
      } else {
        print('Error en la solicitud al servidor: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF154790),
                ),
              ),
              content: Text(
                'Hubo un error al insertar los datos en la base de datos',
                style: TextStyle(color: Color(0xFF154790)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF154790),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al insertar los datos: $e');
      _msgPosiblesInconvenientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(150.0), // Altura personalizada del AppBar
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0), // Radio para el borde circular
          ),
          child: AppBar(
            backgroundColor: Colors.cyan, // Fondo color cyan
            elevation: 0,
            flexibleSpace: Padding(
              padding:
                  const EdgeInsets.only(top: 90.0, left: 50.0, right: 50.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20.0, left: 10.0),
                    child: Text(
                      'Traslado de Datos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 20.0),
                child: Image.asset(
                  'assets/logo.png', // Ruta a tu logo
                  height: 40.0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Seleccione la tabla SQL',
                border: OutlineInputBorder(),
              ),
              value: _tablaSeleccionada,
              onChanged: (String? newValue) {
                setState(() {
                  _tablaSeleccionada = newValue;
                });
              },
              items: <String>[
                'Bodega',
                'Clase_Producto',
                'Marca',
                'Producto',
                'Tipo_Precio',
                'Unidad_Medida',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (_tablaSeleccionada == null) {
                  _msgSeleccionarTablaSQL();
                }
              },
              child: AbsorbPointer(
                absorbing: _tablaSeleccionada == null,
                child: ExpansionTile(
                  backgroundColor: Color.fromARGB(255, 230, 244, 245),
                  title: Text(
                    'Seleccionar archivo excel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onExpansionChanged: (expanded) {
                    if (expanded && _tablaSeleccionada != null) {
                      setState(() {
                        _expandir = expanded;
                      });
                    }
                  },
                  children: [
                    Container(
                      color: Colors.transparent,
                      child: ListTile(
                        onTap: () {
                          _seleccionarArchivo();
                        },
                        title: Text(_archivoSeleccionado?.name ??
                            'Seleccionar archivo de Excel'),
                        leading: _archivoSeleccionado == null
                            ? Icon(Icons.attach_file)
                            : Icon(
                                MdiIcons.fileExcel,
                                color: Color(0xFFDD952A),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (_archivoSeleccionado != null)
                      Text(
                        'Seleccionar una hoja excel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    if (_nombresHojas.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _nombresHojas
                            .map(
                              (sheetName) => Row(
                                children: [
                                  Checkbox(
                                    value: _nombreHojaSeleccionada == sheetName,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value!) {
                                          _nombreHojaSeleccionada = sheetName;
                                        } else {
                                          _nombreHojaSeleccionada = null;
                                        }
                                      });
                                    },
                                    fillColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.selected)) {
                                          return Color(0xFFDC9525);
                                        }
                                        return Colors.white;
                                      },
                                    ),
                                  ),
                                  Text(sheetName),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    if (_archivoSeleccionado != null &&
                        _nombreHojaSeleccionada != null)
                      TextButton(
                        onPressed: () {
                          switch (_tablaSeleccionada) {
                            case "Bodega":
                              _insertBodega();
                            case "Clase_Producto":
                              _insertClaseProducto();
                            case "Marca":
                              _insertMarca();
                            case "Producto":
                              _insertProducto();
                            case "Tipo_Precio":
                              _insertTipoPrecio();
                            case "Unidad_Medida":
                              _insertUnidadMedida();
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_task_sharp,
                              color: Color(0xFFDC9525),
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              'Insertar datos',
                              style: TextStyle(
                                color: Color(0xFFDC9525),
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
