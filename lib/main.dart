import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}
// Reylin Lantigua 20198111
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Emergencias',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const MyHomePage(title: 'Eventos de Emergencia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
 // Reylin Lantigua 20198111
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _event = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedEvents = prefs.getString('events');

    if (storedEvents != null) {
      setState(() {
        _event = List<Map<String, dynamic>>.from(json.decode(storedEvents));
      });
    }
  }

  // Reylin Lantigua 20198111
  void _addEvent(String title, String description, String date, String imagePath) async {
    setState(() {
      _event.add({
        'title': title,
        'description': description,
        'date': date,
        'imagePath': imagePath
      });
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('events', json.encode(_event));
  }

  void _deleteEvent(int index) async {
    setState(() {
      _event.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('events', json.encode(_event));
  }

  void _showAddEventsDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String? imagePath;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titulo'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        imagePath = pickedFile.path;
                      });
                    }
                  },
                  child: const Text('Seleccionar Imagen')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    imagePath != null) {
                  _addEvent(titleController.text, descriptionController.text,
                      DateTime.now().toString(), imagePath!);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _event.isEmpty
          ? const Center(child: Text('No hay eventos registrados.'))
          : ListView.builder(
              itemCount: _event.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _event[index]['imagePath'] != null
                          ? Image.file(
                              File(_event[index]['imagePath']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                    ),
                    title: Text(_event[index]['title']),
                    subtitle: Text(_event[index]['description']),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(_event[index]['title']),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _event[index]['imagePath'] != null
                                    ? Image.file(
                                        File(_event[index]['imagePath']),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported, size: 100),
                              ),
                              const SizedBox(height: 10),
                              Text(_event[index]['description']),
                              const SizedBox(height: 10),
                              Text('Fecha: ${_event[index]['date']}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteEvent(index);
                                Navigator.pop(context);
                              }, // Reylin Lantigua 20198111
                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventsDialog,
        tooltip: 'Agregar Evento',
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
 // Reylin Lantigua 20198111