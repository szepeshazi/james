import 'dart:math';

class NameService {

  final Random random;

  NameService(this.random);

  String get any => names.elementAt(random.nextInt(names.length));

  static const List<String> names = [
    "Juliana",
    "Peggy",
    "Rossie",
    "Rueben",
    "Nakesha",
    "Dannette",
    "Amalia",
    "Candis",
    "Shelia",
    "Robbyn",
    "Kenton",
    "Danuta",
    "Nancee",
    "Tony",
    "Laine",
    "Helene",
    "Julissa",
    "Hilma",
    "Olga",
    "Ashly",
    "Gala",
    "Adam",
    "Anderson",
    "Shanda",
    "Jess",
    "Chassidy",
    "Marie",
    "Lazaro",
    "Verda",
    "Onita",
    "Jayne",
    "Mariella",
    "Zula",
    "Catherine",
    "Reynalda",
    "Deedee",
    "Deadra",
    "Bryan",
    "Maida",
    "Hilda",
    "Marylee",
    "Savannah",
    "Eloisa",
    "Marilynn",
    "Damien",
    "Holly",
    "Usha",
    "Adell",
    "Velma",
    "Candice"
  ];
}