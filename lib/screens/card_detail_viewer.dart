// lib/screens/card_detail_viewer.dart
import 'package:flutter/material.dart';
import 'package:tcg_app/models/card_model.dart';

class CardDetailViewer extends StatefulWidget {
  final List<CardModel> cards;
  final int initialIndex;
  const CardDetailViewer({
    super.key,
    required this.cards,
    required this.initialIndex,
  });
  @override
  State<CardDetailViewer> createState() => _CardDetailViewerState();
}

class _CardDetailViewerState extends State<CardDetailViewer> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(230), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.cards.length,
        itemBuilder: (context, index) {
          final card = widget.cards[index];
          return Center(
            child: AspectRatio(
              aspectRatio: 0.7, // El mismo que el grid para mantener formato carta
              child: Card(
                elevation: 12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    card.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}