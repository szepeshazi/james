import 'dart:async';
import 'dart:html';
import 'dart:math' as math show min, max;

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/utils/disposer/disposer.dart';
import 'package:james/src/card/card.dart';
import 'package:james/src/models/models.dart' as m;

@Component(
    selector: 'player',
    templateUrl: 'player.html',
    styleUrls: ['player.css'],
    directives: [CardComponent, coreDirectives, MaterialButtonComponent],
    exports: [m.SeatLocation],
    changeDetection: ChangeDetectionStrategy.OnPush)
class PlayerComponent implements OnInit, OnDestroy{
  int cardXOffset;
  int cardYOffset;
  int cardWidth;
  int cardSpacing;

  final ChangeDetectorRef changeDetectorRef;
  final Disposer disposer = Disposer.oneShot();

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

  @ViewChild("cardContainer")
  Element cardContainer;

  void arrangeCards() {
    int width = window.innerWidth ?? document.documentElement.clientWidth;
    int height = window.innerHeight ?? document.documentElement.clientHeight;
    Dimension windowSize = Dimension(width, height);
    HandPlacement placement = HandPlacement.calc(player, windowSize);

    for (int i = 0; i < cards.length; i++) {
      cards[i].element.style.left = "${placement.xOffset + (i * placement.cardSpacing)}px";
      cards[i].element.style.top = "${placement.yOffset}px";
      cards[i].element.style.zIndex = "${i * 10}px";
    }

    cardContainer.style.height = "${(placement.cardWidth * CardComponent.heightRatio).round()}px";
    changeDetectorRef.markForCheck();
  }

  void go() {
    selectedCardsController.add(
        cards.where((cardComponent) => cardComponent.selected).map((cardComponent) => cardComponent.card).toList());
  }

  @override
  void ngOnInit() {
    StreamSubscription<Event> resize = window.onResize.listen((_) => arrangeCards());
    disposer.addStreamSubscription(resize);
  }

  @override
  void ngOnDestroy() {
    disposer.dispose();
  }

}

class HandPlacement {
  int xOffset = 0;
  int yOffset = 0;
  int cardWidth;
  int cardSpacing;

  final m.Player player;

  HandPlacement.calc(this.player, Dimension windowSize) {
    recalculate(windowSize);
  }

  recalculate(Dimension windowSize) {
    cardWidth = (windowSize.width * CardComponent.viewportWidthRatio / 100).round();
    cardWidth = math.max(math.min(cardWidth, CardComponent.maxWidth), CardComponent.minWidth);

    cardSpacing = (cardWidth * CardComponent.spacingRatio).round();
    switch (player.location) {
      case m.SeatLocation.east:
        // Anchor to left center
        xOffset = -cardWidth - ((player.hand.cards.length - 1) * cardSpacing).round();
        yOffset = 0;
        break;
      case m.SeatLocation.north:
        // Anchor to center top
        xOffset = -(cardWidth / 2).round() - (player.hand.cards.length * cardSpacing / 2).round();
        yOffset = 0;
        break;
      case m.SeatLocation.west:
        // Anchor to right center
        xOffset = 0;
        yOffset = 0;
        break;
      case m.SeatLocation.south:
        // Anchor to center bottom
        xOffset = -(cardWidth / 2).round() - (player.hand.cards.length * cardSpacing / 2).round();
        //yOffset = -(cardWidth * CardComponent.heightRatio).round();
        yOffset = 0;
        break;
    }
  }
}

class Dimension {
  final int width;
  final int height;

  Dimension(this.width, this.height);
}
