import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final String? username;

  const RegisterScreen({super.key, this.username});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController userCtrl;
  final passCtrl = TextEditingController();
  String message = '';

  @override
  void initState() {
    super.initState();
    userCtrl = TextEditingController(text: widget.username ?? '');
  }

  Future<void> register() async {
    final result = await ApiService.register(userCtrl.text, passCtrl.text);

    setState(() {
      message = result['message'] ?? 'Registrado';
    });

    if (result['token'] != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      await prefs.setString('usuario', userCtrl.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text('Registrar')),
            Text(message),
          ],
        ),
      ),
    );
  }
}
