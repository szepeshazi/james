import 'dart:async';
import 'dart:math';

import 'package:james/src/models/card.dart';
import 'package:james/src/models/game_state.dart';
import 'package:james/src/models/hand.dart';
import 'package:james/src/models/player.dart';

class Game {
  GameLog log;
  Random random;

  Game()
      : log = GameLog()
          ..entries.add(Snapshot()
            ..stock = Deck.shuffled(numOfPacks: 2)
            ..pile = []
            ..discarded = []),
        random = Random();

  List<Player> playersAt(SeatLocation location) =>
      log.entries.last.players.where((player) => player.location == location).toList();

  Future play(UiCallback uiCallback) async {
//    while (players.any((player) => player.active)) {

    // Start with empty hands

    Snapshot state = log.entries.last;
    for (var player in state.players) {
      player.hand = Hand();
    }

    // Deal cards to players still in play
    List<Player> activePlayers = state.players.where((player) => player.active).toList();
    for (var player in activePlayers) {
      await uiCallback(Phase.beforeDeal, player: player, params: {CallbackParam.cardsToDeal: state.cardsToDeal});
    }

    for (int i = 0; i < state.cardsToDeal; i++) {
      for (var player in activePlayers) {
        player.hand.cards.add(state.stock.draw());
        await uiCallback(Phase.deal, player: player, cards: [player.hand.cards.last]);
      }
    }

    for (var player in activePlayers) {
      player.hand.cards.sort();
      await uiCallback(Phase.afterDeal, player: player);
    }

    // Exchange cards
    for (int i = 0; i < state.players.length; i++) {
      int playerOffset = (i + state.dealerIndex) % state.players.length;
      Player player = state.players.elementAt(playerOffset);
      if (!player.active) continue;
      List<Card> selectedCards;
      if (player.computer) {
        selectedCards = player.exchange();
        await uiCallback(Phase.exchange, player: player, cards: selectedCards);
      } else {
        selectedCards = await uiCallback(Phase.exchange, player: player);
      }
      int cardsToReplace = selectedCards.length;
      player.hand.cards.removeWhere((card) => selectedCards.contains(card));
      List<Card> replacementCards = [];
      for (int i = 0; i < cardsToReplace; i++) {
        replacementCards.add(state.stock.draw());
      }
      player.hand.cards.addAll(replacementCards);
      await uiCallback(Phase.replaced, player: player, cards: replacementCards);
      player.hand.cards.sort();
      await uiCallback(Phase.afterExchange, player: player);
    }

    // Play round
    while (activePlayers.any((p) => p.hand.cards.isNotEmpty)) {
      for (int i = 0; i < state.players.length; i++) {
        int playerOffset = (i + state.dealerIndex) % state.players.length;
        Player player = state.players.elementAt(playerOffset);
        if (!player.active) continue;
        List<Card> playedCards;
        if (player.computer) {
          playedCards = player.play(isFirst: i == 0);
          await uiCallback(Phase.playHand, player: player, cards: playedCards);
        } else {
          playedCards = await uiCallback(Phase.playHand, player: player);
        }
        player.hand.cards.removeWhere((card) => playedCards.contains(card));
        state.pile.addAll(playedCards);
        await uiCallback(Phase.afterPlayHand, player: player, cards: playedCards);
      }
    }
  }
}

typedef UiCallback = Future<List<Card>> Function(Phase phase,
    {Player player, List<Card> cards, Map<CallbackParam, dynamic> params});

enum CallbackParam { cardsToDeal }
