import 'package:james/src/models/models.dart';

enum Phase {
  /// Shuffling the deck
  shuffle,
  /// Before dealing cards
  beforeDeal,
  /// After each card dealt
  deal,
  /// After all cards dealt
  afterDeal,
  /// Player exchanges cards
  exchange,
  /// Player receives cards for exchanged cards
  replaced,
  /// Replace phase for given player is done, hand is sorted again
  afterExchange,
  /// Play card(s) for current round
  playHand,
  /// After current round cards played
  afterPlayHand,
  /// End of current round, award scores
  endOfRound,
  /// End of game, announce winner
  endOfGame
}

class Snapshot {
  /// Players in the game
  List<Player> players;

  /// Remaining deck in central area
  Deck stock;

  /// Cards played by players in current round
  List<Card> pile = [];

  /// Cards removed from game after the end of each round
  List<Card> discarded = [];

  /// Round number starting from 1
  int round = 1;

  /// Index of player who deals cards in current round
  int dealerIndex = 0;

  /// Number of cards to deal in current round
  int cardsToDeal = 8;

  /// Current game phase
  Phase phase;

  /// Current player
  Player currentPlayer;

  /// Scores by players
  Map<Player, int> scores = {};

}

abstract class HasCards {
  List<Card> get cards;
}

class Move {
  int round;
  HasCards source;
  HasCards destination;
}

class GameLog {
  List<Move> moves = [];
}
