import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:james/src/card/card.dart';
import 'package:james/src/models/models.dart' as m;

@Component(
    selector: 'player',
    templateUrl: 'player.html',
    styleUrls: ['player.css'],
    directives: [CardComponent, coreDirectives, MaterialButtonComponent],
    exports: [m.SeatLocation],
    changeDetection: ChangeDetectionStrategy.OnPush)
class PlayerComponent {
  final ChangeDetectorRef changeDetectorRef;

  StreamController<List<m.Card>> selectedCardsController = StreamController<List<m.Card>>();

  @Input()
  m.Player player;

  @Input()
  int numOfCards;

  PlayerComponent(this.changeDetectorRef);

  @Output()
  Stream<List<m.Card>> get selectedCards => selectedCardsController.stream;

  @ViewChildren('hand')
  List<CardComponent> cards;

  void arrangeCards() {
    for (int i = 0; i < cards.length; i++) {
      cards[i].element.style.left = "${initialOffset + (cardOffset * i)}px";
      cards[i].element.style.zIndex = "${i * 10}px";
    }
    changeDetectorRef.markForCheck();
  }

  int get initialOffset {
    int offset;
    switch (player.location) {
      case m.SeatLocation.west:
        offset = - (cardWidth ~/ 2);
        break;
      case m.SeatLocation.east:
        offset = -numOfCards * cardOffset;
        break;
      case m.SeatLocation.north:
      case m.SeatLocation.south:
        offset = -(numOfCards ~/ 2) * cardOffset - (cardWidth ~/ 2);
        break;
    }
    return offset;
  }

  void go() {
    selectedCardsController.add(
        cards.where((cardComponent) => cardComponent.selected).map((cardComponent) => cardComponent.card).toList());
  }

  static const int cardOffset = 25;
  static const int cardWidth = 120;
}
