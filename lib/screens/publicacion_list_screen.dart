import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'publicacion_form_screen.dart';
import 'login_screen.dart';

class PublicacionListScreen extends StatefulWidget {
  const PublicacionListScreen({super.key});

  @override
  State<PublicacionListScreen> createState() => _PublicacionListScreenState();
}

class _PublicacionListScreenState extends State<PublicacionListScreen> {
  List<dynamic> publicaciones = [];
  String token = '';
  String autor = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    autor = prefs.getString('usuario') ?? '';
    await loadPublicaciones();
  }

  Future<void> loadPublicaciones() async {
    final data = await ApiService.getPublicaciones(token);
    setState(() {
      publicaciones = data;
    });
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadPublicaciones,
        child: ListView.builder(
          itemCount: publicaciones.length,
          itemBuilder: (context, index) {
            final p = publicaciones[index];
            final id = p['_id']?['\$oid'] ?? p['_id'];
            final titulo = p['titulo'] ?? '';
            final descripcion = p['descripcion'] ?? '';
            final cuerpo = p['cuerpo'] ?? '';
            final autor = p['autor'] ?? '';
            final fechaCreacion = parseDate(p['fecha_creacion']);
            final comentarios = p['comentarios'] as List<dynamic>? ?? [];

            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Por: $autor | ${formatDate(fechaCreacion)}',
                  style: const TextStyle(fontSize: 12),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (descripcion.isNotEmpty) ...[
                          Text(
                            'Descripción:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(descripcion),
                          const SizedBox(height: 8),
                        ],
                        if (cuerpo.isNotEmpty) ...[
                          Text(
                            'Cuerpo:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(cuerpo),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          'Comentarios (${comentarios.length}):',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (comentarios.isEmpty)
                          const Text(
                            'Sin comentarios aún',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          )
                        else
                          ...comentarios.map((c) {
                            final comentarioAutor =
                                c['autor'] ?? c['auter'] ?? 'Unknown';
                            final texto = c['texto'] ?? '';
                            final fecha = parseDate(c['fecha']);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$comentarioAutor - ${formatDate(fecha)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(texto),
                                  ],
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PublicacionFormScreen(
                                      token: token,
                                      publicacion: p,
                                      autor: autor,
                                    ),
                                  ),
                                );
                                loadPublicaciones();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await ApiService.deletePublicacion(token, id);
                                loadPublicaciones();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PublicacionFormScreen(token: token, autor: autor),
            ),
          );
          loadPublicaciones();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
