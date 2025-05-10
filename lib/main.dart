import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Asegúrate de importar también tu pantalla de lista de cartas
import 'package:tcg_app/screens/home_screen.dart';
import 'package:tcg_app/screens/card_list_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCG App',
      theme: ThemeData(primarySwatch: Colors.blue),

      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/cards': (context) => const CardListScreen(),
      },

      // Si prefieres podrías quitar `initialRoute` y usar `home:` en lugar de la ruta "/"
      // home: const HomeScreen(),
    );
  }
}
