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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          card.imageAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            // Sin prints ni badge: solo placeholder
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
  late final CardService _svc;
  late Future<List<EditionMeta>> _editionsFuture;
  late Future<List<CardModel>> _cardsFuture;

  final TextEditingController _searchCtrl = TextEditingController();

  String? _selectedEdition; // null = Todas
  List<CardModel> _allCards = [];
  List<CardModel> _filteredCards = [];

  @override
  void initState() {
    super.initState();
    _svc = CardService();
    _editionsFuture = _svc.loadIndex();
    _cardsFuture = _svc.loadAllCards().then((cards) {
      _allCards = cards;
      _filteredCards = cards;
      return cards;
    });
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filteredCards = _allCards.where((c) {
        final nameMatch = c.name.toLowerCase().contains(q);
        return nameMatch;
      }).toList();
    });
  }

  Future<void> _onEditionChanged(String? editionId) async {
    setState(() => _selectedEdition = editionId);
    final cards = (editionId == null)
        ? await _svc.loadAllCards()
        : await _svc.loadCardsByEdition(editionId);
    setState(() {
      _allCards = cards;
      _applyFilters();
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
          return Stack(
            children: [
              // Fondo con opacidad
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    'assets/images/back.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Contenido
              Column(
                children: [
                  // Fila de filtros (edición + búsqueda)
                  FutureBuilder<List<EditionMeta>>(
                    future: _editionsFuture,
                    builder: (context, snap) {
                      final editions = snap.data ?? const <EditionMeta>[];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Row(
                          children: [
                            const Text('Edición:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            DropdownButton<String?>(
                              value: _selectedEdition,
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Todas'),
                                ),
                                ...editions.map(
                                  (e) => DropdownMenuItem<String?>(
                                    value: e.id,
                                    child: Text(e.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) => _onEditionChanged(val),
                            ),
                            const SizedBox(width: 16),
                            // Buscador
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
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
                          ],
                        ),
                      );
                    },
                  ),
                  // Grid
                  Expanded(
                    child: _filteredCards.isEmpty
                        ? const Center(child: Text('No hay cartas que coincidan'))
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child: GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
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
              ),
            ],
          );
        },
      ),
    );
  }
}

