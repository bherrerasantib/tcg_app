// lib/models/card_model.dart
class CardModel {
  final String id;
  final String name;
  final String edition;
  final String type;
  final String? race;
  final int fuerza;
  final int coste;
  final bool isRework;
  final String? reworkOf;

  // override opcional del archivo (p.ej. "archivo_raro.png")
  final String? image;

  CardModel({
    required this.id,
    required this.name,
    required this.edition,
    required this.type,
    this.race,
    required this.fuerza,
    required this.coste,
    required this.isRework,
    this.reworkOf,
    this.image,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
    id: json['id'],
    name: json['name'],
    edition: json['edition'],
    type: json['type'],
    race: json['race'],
    fuerza: json['fuerza'],
    coste: json['coste'],
    isRework: json['isRework'],
    reworkOf: json['reworkOf'],
    image: json['image'], // opcional
  );

  // Getter para el path de la imagen (usando interpolación)
  String get imageAsset {
    final file = '${image ?? id}.png';
    return 'assets/images/$edition/$file';
  }
}
