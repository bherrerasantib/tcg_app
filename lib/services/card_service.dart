// lib/services/card_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tcg_app/models/card_model.dart';

class CardService {
  Future<List<CardModel>> loadCards() async {
    final jsonStr = await rootBundle.loadString('assets/cards.json');
    final List data = json.decode(jsonStr);
    return data.map((e) => CardModel.fromJson(e)).toList();
  }
}