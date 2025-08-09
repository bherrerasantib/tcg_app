// lib/services/card_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tcg_app/models/card_model.dart';

class EditionMeta {
  final String id;
  final String name;
  final String file;
  final bool enabled;
  EditionMeta({required this.id, required this.name, required this.file, required this.enabled});

  factory EditionMeta.fromJson(Map<String, dynamic> j) => EditionMeta(
    id: j['id'],
    name: j['name'],
    file: j['file'],
    enabled: j['enabled'] ?? true,
  );
}

class CardService {
  List<EditionMeta>? _editions;                 // caché de índice
  final Map<String, List<CardModel>> _cache = {}; // caché por edición

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
    final meta = editions.firstWhere((e) => e.id == editionId);
    final s = await rootBundle.loadString(meta.file);
    final data = json.decode(s) as List;
    final cards = data.map((e) => CardModel.fromJson(e)).toList();
    _cache[editionId] = cards;
    return cards;
  }

  Future<List<CardModel>> loadAllCards() async {
    final editions = await loadIndex();
    final lists = await Future.wait(editions.map((e) => loadCardsByEdition(e.id)));
    return lists.expand((e) => e).toList();
  }
}
