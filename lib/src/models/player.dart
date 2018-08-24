import 'package:james/src/models/hand.dart';

enum SeatLocation {
  north,
  west,
  east,
  south
}

class Player {
  final String name;
  final bool self;
  final bool computer;
  final SeatLocation location;

  Hand hand = Hand();

  Player(this.name, this.self, this.computer, this.location);
}