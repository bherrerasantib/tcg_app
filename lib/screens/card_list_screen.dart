// lib/screens/card_list_screen.dart
import 'package:flutter/material.dart';
import 'package:tcg_app/models/card_model.dart';
import 'package:tcg_app/services/card_service.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  late Future<List<CardModel>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _cardsFuture = CardService().loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Cartas')),
      body: FutureBuilder<List<CardModel>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final cards = snapshot.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,         // dos columnas
              childAspectRatio: 0.7,     // alto vs ancho
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: cards.length,
            itemBuilder: (context, i) {
              final card = cards[i];
              return GestureDetector(
                onTap: () {
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(card.imageAsset, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 4),
                    Text(card.name, textAlign: TextAlign.center),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
