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

  Future play(Tick tick) async {
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
        //await tick(GamePhase.deal);
      }
    }
    for (var player in activePlayers) {
      player.hand.cards.sort();
    }
    await tick(GamePhase.deal);

    // Exchange cards
    for (int i = 0; i < players.length; i++) {
      int playerOffset = (i + dealerIndex) % players.length;
      Player player = players.elementAt(playerOffset);
      if (!player.self) {
        int numOfExchanges = random.nextInt(4);
        List<int> cardIndexes = List.generate(cardsToDeal, (i) => i);
        cardIndexes.shuffle();
        for (var j = 0; j < numOfExchanges; j++) {
          tick(GamePhase.exchange, player:player, cards: [player.hand.cards.elementAt(cardIndexes[j])]);
        }
      }
    }
  }
//  }

}

typedef Tick = Future Function(GamePhase phase, {Player player, List<Card> cards});
