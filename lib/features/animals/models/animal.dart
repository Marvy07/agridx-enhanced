enum AnimalSpecies {
  cattle,
  goat,
  poultry,
  pig,
  dog,
  cat,
}

class Animal {
  final String id;
  final String name;
  final AnimalSpecies species;
  final String description;
  final List<String> commonDiseases;
  final String imageUrl;

  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.description,
    required this.commonDiseases,
    required this.imageUrl,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: AnimalSpecies.values.firstWhere(
        (s) => s.name == json['species'],
        orElse: () => AnimalSpecies.cattle,
      ),
      description: json['description'] as String,
      commonDiseases: List<String>.from(json['common_diseases'] as List),
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species.name,
        'description': description,
        'common_diseases': commonDiseases,
        'image_url': imageUrl,
      };
}
