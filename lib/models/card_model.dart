// lib/models/card_model.dart
class CardModel {
  final String id;
  final String name;
  final String edition;
  final String type;
  final String race;
  final int fuerza;
  final int coste;
  final bool isRework;
  final String? reworkOf;

  CardModel({
    required this.id,
    required this.name,
    required this.edition,
    required this.type,
    required this.race,
    required this.fuerza,
    required this.coste,
    required this.isRework,
    this.reworkOf,
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
      );

  // Getter para el path de la imagen
  String get imageAsset {
    final formattedName = name.toLowerCase().replaceAll(' ', '_');
    return 'assets/images/$edition/$formattedName.png';
  }
}
