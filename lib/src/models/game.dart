import 'dart:async';
import 'dart:math';

import 'package:james/src/models/card.dart';
import 'package:james/src/models/hand.dart';
import 'package:james/src/models/player.dart';

enum GamePhase { shuffle, deal, exchange, select }

class Game {
  List<Player> players;
  Deck deck;
  Random random;

  int dealerIndex = 0;
  int cardsToDeal = 8;

  Game()
      : deck = Deck.shuffled(numOfPacks: 2),
        random = Random();

  List<Player> playersAt(SeatLocation location) => players.where((player) => player.location == location).toList();

  Future play(UiCallback uiCallback) async {
//    while (players.any((player) => player.active)) {

    // Start with empty hands
    for (var player in players) {
      player.hand = Hand();
    }

    // Deal cards to players still in play
    List<Player> activePlayers = players.where((player) => player.active).toList();
    for (int i = 0; i < cardsToDeal; i++) {
      for (var player in activePlayers) {
        player.hand.cards.add(deck.draw());
      }
    }
    for (var player in activePlayers) {
      player.hand.cards.sort();
    }
    await uiCallback(GamePhase.deal);

    // Exchange cards
    for (int i = 0; i < players.length; i++) {
      int playerOffset = (i + dealerIndex) % players.length;
      Player player = players.elementAt(playerOffset);
      if (player.computer) {
        List<Card> selectedCards = player.exchange();
        await uiCallback(GamePhase.exchange, player: player, cards: selectedCards);
      } else {
        List<Card> selectedCards = await uiCallback(GamePhase.exchange, player: player);
        print("Exchanged cards: $selectedCards");
      }
    }
  }
//  }

}

typedef UiCallback = Future<List<Card>> Function(GamePhase phase, {Player player, List<Card> cards});
