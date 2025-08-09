// lib/screens/card_detail_viewer.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tcg_app/models/card_model.dart';
import 'package:tcg_app/services/card_service.dart';

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
  late int _currentIndex;
  late List<CardModel> _cards; // <- lista local mutable

  final _svc = CardService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _cards = List.of(widget.cards); // <- copiamos el dataset recibido
    _controller = PageController(initialPage: widget.initialIndex);
    _prefetchReworksFor(_currentCard);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CardModel get _currentCard => _cards[_currentIndex];

  void _replaceCurrent(CardModel newCard) {
    setState(() {
      _cards[_currentIndex] = newCard;
    });
    _prefetchReworksFor(newCard);
  }

  Future<void> _openOriginal(CardModel rework) async {
    final original = await _svc.getOriginal(rework);
    if (!mounted) return;

    if (original == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Original no encontrado')),
      );
      return;
    }
    _replaceCurrent(original); // <- swap en el mismo carrusel
  }

  Future<void> _openReworks(CardModel base) async {
    final all = await _svc.loadAllCards();
    if (!mounted) return;

    final reworks = all.where((c) => c.isRework && c.reworkOf == base.id).toList();
    if (reworks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta carta no tiene reworks')),
      );
      return;
    }

    if (reworks.length == 1) {
      _replaceCurrent(reworks.first);
      return;
    }

    // Varios reworks: selector simple
    final chosen = await showModalBottomSheet<CardModel>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) {
        return SafeArea(
          child: ListView(
            children: reworks.map((rw) {
              return ListTile(
                leading: const Icon(Icons.style, color: Colors.white),
                title: Text(rw.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(rw.edition, style: const TextStyle(color: Colors.white70)),
                onTap: () => Navigator.pop(context, rw),
              );
            }).toList(),
          ),
        );
      },
    );

    if (!mounted) return;
    if (chosen != null) _replaceCurrent(chosen);
  }

  Widget _actionBar(CardModel card) {
    final isRework = card.isRework && card.reworkOf != null;
    final children = <Widget>[];

    if (isRework) {
      children.add(
        TextButton.icon(
          onPressed: () => _openOriginal(card),
          icon: const Icon(Icons.undo, size: 16),
          label: const Text('Ver original', style: TextStyle(fontSize: 13)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            foregroundColor: Colors.white,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    } else {
      // ORIGINAL: solo muestra botón si tiene reworks
      if (_checkingReworks) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (_hasReworksCurrent) {
        children.add(
          TextButton(
            onPressed: () => _openReworks(card),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepOrange.withValues(alpha: 0.85),
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ver reworks', style: TextStyle(fontSize: 13)),
          ),
        );
      }
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: children,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barra de acciones (con AnimatedSwitcher)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: SizeTransition(sizeFactor: anim, child: child)),
            child: KeyedSubtree(
              key: ValueKey((_baseIdFor(_currentCard), _checkingReworks, _hasReworksCurrent)),
              child: _actionBar(_currentCard),
            ),
          ),

          // Viewer deslizable
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _controller,
                  physics: const PageScrollPhysics(),
                  onPageChanged: (i) {
                    setState(() => _currentIndex = i);
                    _prefetchReworksFor(_cards[i]); // <- _cards
                  },
                  itemCount: _cards.length, // <- _cards
                  itemBuilder: (context, index) {
                    final card = _cards[index]; // <- _cards
                    return Center(child: _TiltAnimatedCard(card: card));
                  },
                ),

                // Flecha izquierda
                if (_cards.length > 1)
                  _NavChevron(
                    alignment: Alignment.centerLeft,
                    enabled: _canGoPrev,
                    icon: Icons.chevron_left,
                    onTap: () => _goRelative(-1),
                  ),

                // Flecha derecha
                if (_cards.length > 1)
                  _NavChevron(
                    alignment: Alignment.centerRight,
                    enabled: _canGoNext,
                    icon: Icons.chevron_right,
                    onTap: () => _goRelative(1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _canGoPrev => _currentIndex > 0;
  bool get _canGoNext => _currentIndex < _cards.length - 1;

  void _goRelative(int delta) {
    final target = (_currentIndex + delta).clamp(0, _cards.length - 1);
    if (target != _currentIndex) {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // Cache: idOriginal -> tiene reworks?
  final Map<String, bool> _hasReworksCache = {};
  bool _hasReworksCurrent = false;
  bool _checkingReworks = false;

  String _baseIdFor(CardModel c) => c.isRework && c.reworkOf != null ? c.reworkOf! : c.id;

  Future<void> _prefetchReworksFor(CardModel c) async {
    final baseId = _baseIdFor(c);

    if (_hasReworksCache.containsKey(baseId)) {
      setState(() => _hasReworksCurrent = _hasReworksCache[baseId]!);
      return;
    }

    setState(() {
      _checkingReworks = true;
      _hasReworksCurrent = false;
    });

    final all = await _svc.loadAllCards();
    if (!mounted) return;

    final hasAny = all.any((x) => x.isRework && x.reworkOf == baseId);
    _hasReworksCache[baseId] = hasAny;

    setState(() {
      _checkingReworks = false;
      _hasReworksCurrent = hasAny;
    });
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

class _NavChevron extends StatelessWidget {
  final Alignment alignment;
  final bool enabled;
  final IconData icon;
  final VoidCallback onTap;

  const _NavChevron({
    required this.alignment,
    required this.enabled,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: IgnorePointer(
          ignoring: !enabled,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1 : 0.35,
            child: Material(
              color: Colors.black.withValues(alpha: 0.4),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: enabled ? onTap : null,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
