import 'package:james/src/models/models.dart';

class GameState {
  List<Player> players;
  Deck deck;
  List<Card> pit;
  List<Card> sink;

  GameState clone() => GameState()
    ..players = List.from(players)
    ..sink = List.from(sink)
    ..pit = List.from(pit)
    ..deck = deck.clone();
}
