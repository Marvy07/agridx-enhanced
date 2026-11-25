// Curated Unsplash image IDs for consistent photography throughout the app.
// Format: https://images.unsplash.com/photo-{id}?w=800&q=80&fit=crop
class AppImages {
  AppImages._();

  static String unsplash(String id, {int w = 800, int q = 80}) =>
      'https://images.unsplash.com/photo-$id?w=$w&q=$q&fit=crop&auto=format';

  // Hero / onboarding
  static final String heroFarm = unsplash('1500651903759-b89368fca3a4');
  static final String heroFarmer = unsplash('1464226184884-fa280b87c399');
  static final String heroAfrica = unsplash('1591615765741-8c06cfc61a73');

  // Crops
  static final String cropMaize = unsplash('1601646143387-b1a2a39e95e9');
  static final String cropCassava = unsplash('1618325778665-9b2f20d50673');
  static final String cropTomato = unsplash('1592924357228-a4f56bb95a9b');
  static final String cropRice = unsplash('1536405528985-b80c4a7f2e3f');
  static final String cropBanana = unsplash('1571771894842-80c5b89a4b3f');
  static final String cropCoffee = unsplash('1447933601403-0c6688de566e');
  static final String cropCocoa = unsplash('1551845728-e30f56d3f7a7');
  static final String cropMango = unsplash('1601004890108-d7a5e3f7f3e3');
  static final String cropSoybean = unsplash('1559827260-dc66d52bef19');
  static final String cropWheat = unsplash('1500382017468-9049fed747ef');

  // Animals
  static final String animalCattle = unsplash('1596733430284-f7437764b1a9');
  static final String animalGoat = unsplash('1570042239135-7c0f4d33d2d4');
  static final String animalPoultry = unsplash('1548550023-2a9d8c2ea5e5');
  static final String animalPig = unsplash('1548082162-7f8d4d35b5f8');
  static final String animalDog = unsplash('1587300003388-59208cc962cb');
  static final String animalCat = unsplash('1514888286974-6c03e2ca1dba');

  // Detection / scanning
  static final String scanLeaf = unsplash('1416879595882-3373a0480b5b');
  static final String scanField = unsplash('1500382017468-9049fed747ef');
  static final String diseaseExamplePlant = unsplash('1572726741897-9b56b06e0b75');

  // Community
  static final String communityFarmer = unsplash('1559599101-f09722fb4948');
  static final String communityField = unsplash('1464226184884-fa280b87c399');

  // Placeholder / fallback
  static final String placeholder = unsplash('1416879595882-3373a0480b5b');
}
