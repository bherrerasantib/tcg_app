// lib/services/card_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tcg_app/models/card_model.dart';

class EditionMeta {
  final String id;
  final String name;
  final String file;
  final bool enabled;

  EditionMeta({
    required this.id,
    required this.name,
    required this.file,
    required this.enabled,
  });

  factory EditionMeta.fromJson(Map<String, dynamic> j) => EditionMeta(
        id: j['id'],
        name: j['name'],
        file: j['file'],
        enabled: j['enabled'] ?? true,
      );
}

class CardService {
  List<EditionMeta>? _editions;                       // caché del índice
  final Map<String, List<CardModel>> _cache = {};     // caché por edición
  final Map<String, CardModel> _byId = {};            // índice global id -> carta

  Future<List<EditionMeta>> loadIndex() async {
    if (_editions != null) return _editions!;
    final s = await rootBundle.loadString('assets/cards/index.json');
    final m = json.decode(s) as Map<String, dynamic>;
    final list = (m['editions'] as List).map((e) => EditionMeta.fromJson(e)).toList();
    _editions = list.where((e) => e.enabled).toList();
    return _editions!;
  }

  Future<List<CardModel>> loadCardsByEdition(String editionId) async {
    if (_cache.containsKey(editionId)) return _cache[editionId]!;

    final editions = await loadIndex();
    final meta = editions.firstWhere(
      (e) => e.id == editionId,
      orElse: () => throw StateError('Edición no encontrada: $editionId'),
    );

    final s = await rootBundle.loadString(meta.file);
    final List<dynamic> data = json.decode(s) as List<dynamic>;
    final cards = data.map((e) => CardModel.fromJson(e as Map<String, dynamic>)).toList();

    // guarda en caché por edición
    _cache[editionId] = cards;

    // actualiza índice global por id
    for (final c in cards) {
      _byId[c.id] = c; // si hay ids repetidos, el último gana
    }

    return cards;
  }

  Future<List<CardModel>> loadAllCards() async {
    final editions = await loadIndex();
    final lists = await Future.wait(editions.map((e) => loadCardsByEdition(e.id)));
    // ya se llenó _byId dentro de loadCardsByEdition
    return lists.expand((e) => e).toList();
  }

  /// Obtiene por id; asegura que el índice esté cargado.
  Future<CardModel?> getById(String id) async {
    if (_byId.isEmpty) {
      await loadAllCards();
    }
    return _byId[id];
  }

  /// Devuelve el original de una carta rework (o null si no aplica).
  Future<CardModel?> getOriginal(CardModel card) async {
    if (!card.isRework || card.reworkOf == null) return null;
    return getById(card.reworkOf!);
  }

  /// Lista todas las cartas que son rework de `baseId`.
  Future<List<CardModel>> getReworksOf(String baseId) async {
    if (_byId.isEmpty) {
      await loadAllCards();
    }
    return _byId.values
        .where((c) => c.isRework && c.reworkOf == baseId)
        .toList();
  }
}
