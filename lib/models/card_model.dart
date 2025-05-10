// lib/models/card_model.dart
class CardModel {
  final String id;
  final String name;
  final String imageAsset;


  CardModel({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json['id'] as String,
        name: json['name'] as String,
        imageAsset: json['imageAsset'] as String,
      );
}