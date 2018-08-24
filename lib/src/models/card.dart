enum Suit { Clubs, Diamonds, Hearts, Spades }

enum Rank { Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace }

String enumName(dynamic value) => value.toString().split(".").last;

class Card {
  final Suit suit;
  final Rank rank;

  Card(this.suit, this.rank);

  String get rankText => enumName(rank);

  String get suitText => enumName(suit);

  @override
  String toString() =>  "$rankText of $suitText";
}

class Deck {
  List<Card> cards;

  Deck._(this.cards);

  factory Deck.ordered({int numOfPacks: 1}) {
    return Deck._(_open(numOfPacks: numOfPacks));
  }

  factory Deck.shuffled({int numOfPacks}) {
    List<Card> cards = _open(numOfPacks: numOfPacks);
    cards.shuffle();
    return Deck._(cards);
  }

  static List<Card> _open({int numOfPacks: 1}) {
    List<Card> cards = new List<Card>();
    for (var count = 0; count < numOfPacks; count++) {
      for (var suit in Suit.values) {
        for (var rank in Rank.values) {
          cards.add(Card(suit, rank));
        }
      }
    }
    return cards;
  }

  Card draw() {
    Card card;
    if (cards.isNotEmpty) {
      card = cards.removeLast();
    } else {
      throw StateError("draw: Deck is empty");
    }
    return card;
  }

  bool get hasMore => cards.isNotEmpty;
}
