// lib/screens/card_list_screen.dart
import 'package:flutter/material.dart';
import 'package:tcg_app/models/card_model.dart';
import 'package:tcg_app/services/card_service.dart';

class _CartaWidget extends StatelessWidget {
  final CardModel card;
  const _CartaWidget({required this.card});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40), // sombra más natural
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
              child: SizedBox(
                height: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.asset(
                    card.imageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                card.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                    : _filteredCards.length < 3
                        ? Center(
                            child: SizedBox(
                              width: 220, // Ajusta para el tamaño de tus cartas
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _filteredCards.length,
                                itemBuilder: (context, i) {
                                  final card = _filteredCards[i];
                                  return _CartaWidget(card: card);
                                },
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredCards.length,
                            itemBuilder: (context, i) {
                              final card = _filteredCards[i];
                              return _CartaWidget(card: card);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
