import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PublicacionFormScreen extends StatefulWidget {
  final String token;
  final dynamic publicacion;

  const PublicacionFormScreen({
    super.key,
    required this.token,
    this.publicacion,
  });

  @override
  State<PublicacionFormScreen> createState() => _PublicacionFormScreenState();
}

class _PublicacionFormScreenState extends State<PublicacionFormScreen> {
  late TextEditingController tituloCtrl;
  late TextEditingController descripcionCtrl;
  late TextEditingController cuerpoCtrl;

  @override
  void initState() {
    super.initState();
    tituloCtrl = TextEditingController(
      text: widget.publicacion?['titulo'] ?? '',
    );
    descripcionCtrl = TextEditingController(
      text: widget.publicacion?['descripcion'] ?? '',
    );
    cuerpoCtrl = TextEditingController(
      text: widget.publicacion?['cuerpo'] ?? '',
    );
  }

  DateTime parseDate(dynamic dateValue) {
    if (dateValue is Map && dateValue.containsKey('\$date')) {
      return DateTime.parse(dateValue['\$date']);
    } else if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (time != null && mounted) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          _selectedDateTime = dateTime;
        });
      }
    }
  }

  DateTime _selectedDateTime = DateTime.now();

  Future<void> savePublicacion() async {
    final fields = {
      'titulo': tituloCtrl.text,
      'descripcion': descripcionCtrl.text,
      'cuerpo': cuerpoCtrl.text,
      'fecha_creacion': _selectedDateTime.toIso8601String(),
    };

    final id =
        widget.publicacion?['_id']?['\$oid'] ?? widget.publicacion?['_id'];

    if (id == null) {
      await ApiService.createPublicacion(widget.token, fields);
    } else {
      await ApiService.updatePublicacion(widget.token, id, fields);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final existingDate = widget.publicacion?['fecha_creacion'];
    if (existingDate != null) {
      _selectedDateTime = parseDate(existingDate);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.publicacion == null
              ? 'Nueva Publicación'
              : 'Editar Publicación',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cuerpoCtrl,
              decoration: const InputDecoration(labelText: 'Cuerpo'),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha de Creación'),
              subtitle: Text(formatDate(_selectedDateTime)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: savePublicacion,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
