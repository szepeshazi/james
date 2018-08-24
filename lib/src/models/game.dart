import 'package:james/src/models/card.dart';
import 'package:james/src/models/player.dart';

class Game {
  List<Player> players;
  Deck deck;

  Game() : deck = Deck.shuffled(numOfPacks: 2);

  List<Player> playersAt(SeatLocation location) => players.where((player) => player.location == location).toList();

}