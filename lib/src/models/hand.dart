import 'package:james/src/models/card.dart';

class Hand {
  List<Card> cards = [];

  Hand clone() => Hand()..cards = List.from(cards);

  @override
  String toString() => cards.join(", ");
}