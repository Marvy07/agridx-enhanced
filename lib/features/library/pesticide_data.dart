class PesticideDetails {
  final String name;
  final String type; // 'Insecticide', 'Fungicide', 'Herbicide', etc.
  final String activeIngredient;
  final String targetPests;
  final String dosage;
  final String applicationMethod;
  final String safetyPrecautions;
  final String warning;

  const PesticideDetails({
    required this.name,
    required this.type,
    required this.activeIngredient,
    required this.targetPests,
    required this.dosage,
    required this.applicationMethod,
    required this.safetyPrecautions,
    required this.warning,
  });
}

const List<PesticideDetails> availablePesticides = [
  PesticideDetails(
    name: 'Neem Oil',
    type: 'Insecticide / Fungicide',
    activeIngredient: 'Azadirachtin',
    targetPests: 'Aphids, Mites, Whiteflies, Powdery Mildew',
    dosage: '2-4 tbsp per gallon of water',
    applicationMethod: 'Foliar spray. Apply in early morning or late evening.',
    safetyPrecautions: 'Wear gloves and long sleeves. Safe for beneficial insects when dried.',
    warning: 'Can burn leaves if applied in direct sunlight.',
  ),
  PesticideDetails(
    name: 'Spinosad',
    type: 'Insecticide',
    activeIngredient: 'Spinosyn A and D',
    targetPests: 'Caterpillars, Thrips, Leafminers, Fruit Flies',
    dosage: '4 tbsp per gallon of water',
    applicationMethod: 'Foliar spray. Coat leaves thoroughly on top and bottom.',
    safetyPrecautions: 'Toxic to bees when wet. Apply only at dusk.',
    warning: 'Do not make more than 6 applications per year to prevent resistance.',
  ),
  PesticideDetails(
    name: 'Copper Fungicide',
    type: 'Fungicide',
    activeIngredient: 'Copper Octanoate or Copper Sulfate',
    targetPests: 'Late Blight, Downy Mildew, Leaf Spot',
    dosage: '0.5 - 2.0 oz per gallon of water',
    applicationMethod: 'Foliar spray. Use preventatively before disease spreads.',
    safetyPrecautions: 'Wear protective eyewear and gloves. Can be irritating to skin.',
    warning: 'Can cause phytotoxicity on some plants if applied above 85°F (29°C).',
  ),
  PesticideDetails(
    name: 'Glyphosate (Roundup)',
    type: 'Herbicide',
    activeIngredient: 'Glyphosate',
    targetPests: 'Broadleaf weeds, grasses',
    dosage: '2.5 oz per gallon of water',
    applicationMethod: 'Spot spray on target weeds. Non-selective.',
    safetyPrecautions: 'Wear heavy gloves, mask, and long pants. Wash hands thoroughly.',
    warning: 'Kills any plant it touches. Do not spray on windy days.',
  ),
  PesticideDetails(
    name: 'Imidacloprid',
    type: 'Systemic Insecticide',
    activeIngredient: 'Imidacloprid',
    targetPests: 'Aphids, Mealybugs, Root Borers, Whiteflies',
    dosage: '1 oz per gallon of water (soil drench)',
    applicationMethod: 'Apply as a soil drench around the base of the plant.',
    safetyPrecautions: 'Wear gloves. Extremely toxic to bees and aquatic invertebrates.',
    warning: 'Do not apply to flowering plants or crops while bees are foraging.',
  ),
  PesticideDetails(
    name: 'Bacillus thuringiensis (Bt)',
    type: 'Biological Insecticide',
    activeIngredient: 'Bacillus thuringiensis kurstaki',
    targetPests: 'Caterpillars, Hornworms, Cabbage Loopers',
    dosage: '1-2 tbsp per gallon of water',
    applicationMethod: 'Foliar spray on affected leaves. Needs to be ingested by pest.',
    safetyPrecautions: 'Generally safe, but standard PPE (gloves/mask) recommended.',
    warning: 'Breaks down quickly in sunlight. Reapply after rain.',
  ),
];
