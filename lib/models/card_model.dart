// lib/models/card_model.dart
class CardModel {
  final String id;
  final String name;

  CardModel({
    required this.id,
    required this.name,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  // Getter que genera automáticamente el path del asset
  String get imageAsset {
    final formattedName = name.toLowerCase().replaceAll(' ', '_');
    return 'assets/images/$formattedName.png';
  }
}
