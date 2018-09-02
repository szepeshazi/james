import 'dart:async';
import 'dart:math';

import 'package:james/src/models/card.dart';
import 'package:james/src/models/hand.dart';
import 'package:james/src/models/player.dart';

enum GamePhase { shuffle, beforeDeal, deal, afterDeal, exchange, replaced, select }

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
    for (var player in activePlayers) {
      await uiCallback(GamePhase.beforeDeal, player: player, additionalParams: {"cardsToDeal" : cardsToDeal});
    }

    for (int i = 0; i < cardsToDeal; i++) {
      for (var player in activePlayers) {
        player.hand.cards.add(deck.draw());
        await uiCallback(GamePhase.deal, player: player, cards: [player.hand.cards.last]);
      }
    }

    for (var player in activePlayers) {
      player.hand.cards.sort();
      await uiCallback(GamePhase.afterDeal, player: player);
    }

    // Exchange cards
    for (int i = 0; i < players.length; i++) {
      int playerOffset = (i + dealerIndex) % players.length;
      Player player = players.elementAt(playerOffset);
      List<Card> selectedCards;
      if (player.computer) {
        selectedCards = player.exchange();
        await uiCallback(GamePhase.exchange, player: player, cards: selectedCards);
      } else {
        selectedCards = await uiCallback(GamePhase.exchange, player: player);
      }
      int cardsToReplace = selectedCards.length;
      player.hand.cards.removeWhere((card) => selectedCards.contains(card));
      List<Card> replacementCards = [];
      for (int i = 0; i < cardsToReplace; i++) {
        replacementCards.add(deck.draw());
      }
      player.hand.cards.addAll(replacementCards);
      await uiCallback(GamePhase.replaced, player: player, cards: replacementCards);
    }
  }
//  }

}

typedef UiCallback = Future<List<Card>> Function(GamePhase phase,
    {Player player, List<Card> cards, Map<String, dynamic> additionalParams});
