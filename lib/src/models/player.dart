import 'dart:math' show Random;

import 'package:james/src/models/card.dart';
import 'package:james/src/models/hand.dart';

enum SeatLocation { north, west, east, south }

class Player {
  final String name;
  final bool self;
  final bool computer;
  final SeatLocation location;

  Hand hand = Hand();
  Random random = Random();

  bool active = true;

  Player._(this.name, this.self, this.location, {this.computer});

  factory Player.ai(String name, bool self, SeatLocation location) => Player._(name, self, location, computer: true);

  factory Player.human(String name, bool self, SeatLocation location) =>
      Player._(name, self, location, computer: false);

  List<Card> exchange() {
    if (!computer) {
      throw StateError("Human players need to select cards to exchange manually");
    }
    Map<Rank, int> cardRankOccurrences = {};
    for (var card in hand.cards) {
      cardRankOccurrences[card.rank] ??= 0;
      cardRankOccurrences[card.rank]++;
    }
    int index = 0;
    Map<int, int> cardScores = new Map.fromIterable(hand.cards,
        key: (_) => index++, value: (card) => cardWeights[card.rank] * cardRankOccurrences[card.rank]);

    int numOfExchanges = random.nextInt(3) + 1;
    List<int> cardIndexes = List.generate(hand.cards.length, (i) => i);
    cardIndexes.shuffle();
    List<Card> exchanges = [];
    for (var i = 0; i < numOfExchanges; i++) {
      exchanges.add(hand.cards[cardIndexes[i]]);
    }
    return exchanges;
  }

  @override
  String toString() => "$name $hand";

  static const Map<Rank, int> cardWeights = {
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
}
