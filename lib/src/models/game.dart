import 'dart:async';
import 'dart:math';

import 'package:james/src/models/card.dart';
import 'package:james/src/models/game_state.dart';
import 'package:james/src/models/hand.dart';
import 'package:james/src/models/player.dart';

enum GamePhase {
  // Shuffling the deck
  shuffle,
  // Before dealing cards
  beforeDeal,
  // After each card dealt
  deal,
  // After all cards dealt
  afterDeal,
  // Player exchanges cards
  exchange,
  // Player receives cards for exchanged cards
  replaced,
  // Replace phase for given player is done, hand is sorted again
  afterExchange,
  round,
  afterRound
}

class Sink {
  List<Card> cards;
}

class PlayedHand {
  Player player;
  List<Card> cards;
}

class Pit {
  List<PlayedHand> stack;
}

class Game {
  GameState state;
  Random random;

  int dealerIndex = 0;
  int cardsToDeal = 8;

  Game()
      : state = GameState()..deck = Deck.shuffled(numOfPacks: 2),
        random = Random();

  List<Player> playersAt(SeatLocation location) => state.players.where((player) => player.location == location).toList();

  Future play(UiCallback uiCallback) async {
//    while (players.any((player) => player.active)) {

    // Start with empty hands
    for (var player in state.players) {
      player.hand = Hand();
    }

    // Deal cards to players still in play
    List<Player> activePlayers = state.players.where((player) => player.active).toList();
    for (var player in activePlayers) {
      await uiCallback(GamePhase.beforeDeal, player: player, params: {CallbackParam.cardsToDeal: cardsToDeal});
    }

    for (int i = 0; i < cardsToDeal; i++) {
      for (var player in activePlayers) {
        player.hand.cards.add(state.deck.draw());
        await uiCallback(GamePhase.deal, player: player, cards: [player.hand.cards.last]);
      }
    }

    for (var player in activePlayers) {
      player.hand.cards.sort();
      await uiCallback(GamePhase.afterDeal, player: player);
    }

    // Exchange cards
    for (int i = 0; i < state.players.length; i++) {
      int playerOffset = (i + dealerIndex) % state.players.length;
      Player player = state.players.elementAt(playerOffset);
      if (!player.active) continue;
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
        replacementCards.add(state.deck.draw());
      }
      player.hand.cards.addAll(replacementCards);
      await uiCallback(GamePhase.replaced, player: player, cards: replacementCards);
      player.hand.cards.sort();
      await uiCallback(GamePhase.afterExchange, player: player);
    }

    // Play round
    while (activePlayers.any((p) => p.hand.cards.isNotEmpty)) {
      for (int i = 0; i < state.players.length; i++) {
        int playerOffset = (i + dealerIndex) % state.players.length;
        Player player = state.players.elementAt(playerOffset);
        if (!player.active) continue;
        List<Card> playedCards;
        if (player.computer) {
          playedCards = player.play(isFirst: i == 0);
          await uiCallback(GamePhase.round, player: player, cards: playedCards);
        } else {
          playedCards = await uiCallback(GamePhase.round, player: player);
        }
        player.hand.cards.removeWhere((card) => playedCards.contains(card));
        await uiCallback(GamePhase.afterRound, player: player, cards: playedCards);
      }
    }
  }
}

typedef UiCallback = Future<List<Card>> Function(GamePhase phase,
    {Player player, List<Card> cards, Map<CallbackParam, dynamic> params});


enum CallbackParam {
  cardsToDeal
}