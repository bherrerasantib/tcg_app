// lib/screens/card_list_screen.dart
import 'package:flutter/material.dart';
import 'package:tcg_app/models/card_model.dart';
import 'package:tcg_app/services/card_service.dart';
import 'package:tcg_app/screens/card_detail_viewer.dart';

class _CartaWidget extends StatelessWidget {
  final CardModel card;
  const _CartaWidget({required this.card});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          card.imageAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          // Aquí está la magia:
          errorBuilder: (context, error, stackTrace) {
            // Puedes poner aquí un asset genérico
            return Image.asset(
              'assets/images/placeholder.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          },
        ),
      ),
    );
  }
}

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  late Future<List<CardModel>> _cardsFuture;
  List<CardModel> _allCards = [];
  List<CardModel> _filteredCards = [];

  @override
  void initState() {
    super.initState();
    _cardsFuture = CardService().loadCards().then((cards) {
      _allCards = cards;
      _filteredCards = cards;
      return cards;
    });
  }

  void _filterCards(String query) {
    setState(() {
      _filteredCards = _allCards.where((card) {
        return card.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
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
          // Se usa _filteredCards para mostrar resultados
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: _filterCards,
                  decoration: InputDecoration(
                    hintText: 'Buscar carta...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    fillColor: Colors.white.withAlpha((0.9 * 255).toInt()),
                    filled: true,
                  ),
                ),
              ),
              Expanded(
                child: _filteredCards.isEmpty
                    ? const Center(child: Text('No hay cartas que coincidan'))
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200), // Ajusta a tu gusto
                          child: GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,           // Hasta 6 cartas por fila
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredCards.length,
                          itemBuilder: (context, i) {
                            final card = _filteredCards[i];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CardDetailViewer(
                                      cards: _filteredCards,
                                      initialIndex: i,
                                    ),
                                  ),
                                );
                              },
                              child: _CartaWidget(card: card),
                            );
                          },
                                                    ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
