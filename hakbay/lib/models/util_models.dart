class Interest {
  static const String hiking = "Hiking";
  static const String food = "Food";
  static const String art = "Art";
  static const String books = "Books";
  static const String museums = "Museums";
  static const String festivals = "Festivals";
  static const String theatre = "Theatre";
  static const String streetFood = "Street Food";

  static List<String> get all => [
    hiking,
    food,
    art,
    books,
    museums,
    festivals,
    theatre,
    streetFood,
  ];
}

class TravelStyle {
  static const String lightPacker = "Light Packer";
  static const String adventurer = "Adventurer";
  static const String frequentFlyer = "Frequent Flyer";
  static const String cultureSeeker = "Culture Seeker";
  static const String leisure = "Leisure";
  static const String planner = "Planner";

  static List<String> get all => [
    lightPacker,
    frequentFlyer,
    adventurer,
    cultureSeeker,
    planner,
  ];
}
