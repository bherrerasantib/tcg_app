// lib/screens/card_detail_viewer.dart
import 'package:flutter/material.dart';
import 'package:tcg_app/models/card_model.dart';
import 'package:flutter/gestures.dart';

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
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.cards.length,
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return Center(
                child: _TiltAnimatedCard(card: card),
              );
            },
          ),
          // Botón izquierda
          Positioned(
            left: 24,
            child: IconButton(
              icon: Icon(Icons.chevron_left, size: 40, color: Colors.white),
              onPressed: () {
                if (_controller.page != null && _controller.page! > 0) {
                  _controller.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
            ),
          ),
          // Botón derecha
          Positioned(
            right: 24,
            child: IconButton(
              icon: Icon(Icons.chevron_right, size: 40, color: Colors.white),
              onPressed: () {
                if (_controller.page != null && _controller.page! < widget.cards.length - 1) {
                  _controller.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TiltAnimatedCard extends StatefulWidget {
  final CardModel card;
  const _TiltAnimatedCard({required this.card});

  @override
  State<_TiltAnimatedCard> createState() => _TiltAnimatedCardState();
}

class _TiltAnimatedCardState extends State<_TiltAnimatedCard> {
  double _dx = 0;
  double _dy = 0;

  void _updateTilt(PointerHoverEvent event, BoxConstraints constraints) {
    final size = constraints.biggest;
    final localPos = event.localPosition;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    setState(() {
      _dx = (localPos.dx - centerX) / centerX;
      _dy = (localPos.dy - centerY) / centerY;
    });
  }

  void _resetTilt(PointerExitEvent event) {
    setState(() {
      _dx = 0;
      _dy = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _updateTilt(event, constraints),
          onExit: _resetTilt,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateX(-_dy * 0.10)
              ..rotateY(_dx * 0.10),
            child: AspectRatio(
              aspectRatio: 0.7,
              child: Card(
                elevation: 18,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.card.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
