import 'dart:math' show Random;

import 'package:james/src/models/card.dart';
import 'package:james/src/models/game_state.dart';
import 'package:james/src/models/hand.dart';

enum SeatLocation { north, west, east, south }

class Player implements HasCards {
  final String name;
  final bool self;
  final bool computer;
  final SeatLocation location;

  Hand hand = Hand();
  Random random = Random();

  bool active = true;

  List<Card> get cards => hand.cards;

  Player._(this.name, this.self, this.location, {this.computer});

  factory Player.ai(String name, bool self, SeatLocation location) => Player._(name, self, location, computer: true);

  factory Player.human(String name, bool self, SeatLocation location) =>
      Player._(name, self, location, computer: false);

  List<Card> exchange() {
    if (!computer) {
      throw StateError("Human players need to select cards to exchange manually");
    }
    Map<Rank, int> cardScores = new Map.fromIterable(hand.cards,
        key: (card) => card.rank, value: (card) => cardExchangeWeights[card.rank] * cardRankOccurrences[card.rank]);

    int numOfExchanges = random.nextInt(3) + 1;
    List<int> cardIndexes = List.generate(hand.cards.length, (i) => i);
    cardIndexes.shuffle();
    List<Card> exchanges = [];
    for (var i = 0; i < numOfExchanges; i++) {
      exchanges.add(hand.cards[cardIndexes[i]]);
    }
    return exchanges;
  }

  Map<Rank, int> get cardRankOccurrences {
    Map<Rank, int> occurrences = {};
    for (var card in hand.cards) {
      occurrences[card.rank] ??= 0;
      occurrences[card.rank]++;
    }
    return occurrences;
  }

  List<Card> play({bool isFirst}) {
    List<Card> played = [];
    if (isFirst) {
      Map<Rank, int> cardScores = {};
      for (Card card in hand.cards) {
        cardScores[card.rank] ??= 0;
        cardScores[card.rank] += cardRoundStartWeights[card.rank];
      }
      Rank maxValueRank =
          cardScores.keys.reduce((rank, nextRank) => cardScores[rank] > cardScores[nextRank] ? rank : nextRank);
      played = hand.cards.where((card) => card.rank == maxValueRank).toList();
    } else {
      played.add(hand.cards.last);
    }
    return played;
  }

  Player clone() => Player._(name, self, location, computer: computer)
    ..hand = hand.clone()
    ..active = active;

  @override
  String toString() => "$name $hand";

  static const Map<Rank, int> cardExchangeWeights = {
    Rank.Two: 100,
    Rank.Three: 80,
    Rank.Four: 60,
    Rank.Five: 40,
    Rank.Six: 20,
    Rank.Seven: 0,
    Rank.Eight: 0,
    Rank.Nine: 0,
    Rank.Ten: 20,
    Rank.Jack: 40,
    Rank.Queen: 60,
    Rank.King: 80,
    Rank.Ace: 100
  };

  static const Map<Rank, int> cardRoundStartWeights = {
    Rank.Two: 0,
    Rank.Three: 10,
    Rank.Four: 20,
    Rank.Five: 30,
    Rank.Six: 40,
    Rank.Seven: 50,
    Rank.Eight: 60,
    Rank.Nine: 70,
    Rank.Ten: 80,
    Rank.Jack: 100,
    Rank.Queen: 120,
    Rank.King: 140,
    Rank.Ace: 160
  };
}
