import 'dart:async';

import 'package:james/src/models/card.dart';
import 'package:james/src/models/hand.dart';
import 'package:james/src/models/player.dart';

enum GamePhase {
  shuffle,
  deal,
  exchange,
  select
}

class Game {
  List<Player> players;
  Deck deck;

  int dealerIndex = 0;
  int cardsToDeal = 8;

  Game() : deck = Deck.shuffled(numOfPacks: 2);

  List<Player> playersAt(SeatLocation location) => players.where((player) => player.location == location).toList();

  Future play(Tick callback) async {

//    while (players.any((player) => player.active)) {
      for (var player in players) {
        player.hand = Hand();
      }
      List<Player> activePlayers = players.where((player) => player.active).toList();
      for (int i = 0; i < cardsToDeal; i++) {
        for (var player in activePlayers) {
          player.hand.cards.add(deck.draw());
          await callback(GamePhase.deal);
        }
      }
      for (var player in activePlayers) {
        player.hand.cards.sort();
      }
      await callback(GamePhase.exchange);
    }
//  }

}

typedef Tick = Future Function(GamePhase phase);
