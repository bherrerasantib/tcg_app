// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi TCG App'),
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido a tu primera pantalla!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
