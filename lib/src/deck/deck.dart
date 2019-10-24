import 'dart:async';
import 'dart:html';
import 'dart:math' as math show min, max, Random;

import 'package:angular/angular.dart';
import 'package:angular_components/utils/disposer/disposer.dart';
import 'package:james/src/card/card.dart';
import 'package:james/src/models/models.dart';

@Component(
    selector: 'deck',
    templateUrl: 'deck.html',
    styleUrls: ['deck.css'],
    directives: [coreDirectives, CardComponent],
    changeDetection: ChangeDetectionStrategy.OnPush)
class DeckComponent implements OnInit, OnDestroy, AfterViewInit {
  final ChangeDetectorRef changeDetectorRef;
  final Disposer disposer = Disposer.oneShot();
  final math.Random random = math.Random();

  @ViewChildren("deck")
  List<CardComponent> deckCards;

  @ViewChildren("pile")
  List<CardComponent> pileCards;

  @ViewChild("deckContainer")
  Element deckContainer;

  @ViewChild("pileContainer")
  Element pileContainer;

  DeckComponent(this.changeDetectorRef);

  List<Card> deckRepresentation;

  List<CardTransformation> pileTransformations;
  Snapshot _gameState;

  Snapshot get gameState => _gameState;

  @Input()
  set gameState(Snapshot newValue) {
    _gameState = newValue;
    pileTransformations ??= [];
    CardTransformation prevTrans = pileTransformations.length > 0 ? pileTransformations.last : null;
    List<CardTransformation> newTransformations = [];
    for (int i = pileTransformations.length; i < gameState.pile.length; i++) {
      int rotationDelta = (prevTrans?.rotation ?? 0) +
          (random.nextBool() ? -1 : 1) * (random.nextInt(rotationMaxChange - rotationMinChange) + rotationMinChange);
      newTransformations.add(CardTransformation((random.nextBool() ? -1 : 1) * (random.nextInt(xOffsetMaxChange)), (random.nextBool() ? -1 : 1) * (random.nextInt(yOffsetMaxChange)), rotationDelta));
      prevTrans = newTransformations.last;
    }
    pileTransformations.addAll(newTransformations);
  }



  @override
  void ngOnInit() {
    deckRepresentation = gameState.stock.cards.skip((gameState.stock.cards.length * 9 ~/ 10) - 1).toList();
    StreamSubscription<Event> resize = window.onResize.listen((_) => arrangeCards());
    disposer.addStreamSubscription(resize);
  }

  @override
  void ngAfterViewInit() {
    arrangeCards();
  }

  @override
  void ngOnDestroy() {
    disposer.dispose();
  }

  Future arrangeCards() async {
    if (deckCards == null || pileCards == null) return;

    deckRepresentation = gameState.stock.cards.skip((gameState.stock.cards.length * 9 ~/ 10) - 1).toList();
    int width = window.innerWidth ?? document.documentElement.clientWidth;
    int cardWidth = (width * CardComponent.viewportWidthRatio / 100).round();
    cardWidth = math.max(math.min(cardWidth, CardComponent.maxWidth), CardComponent.minWidth);

    int xOffset = -(cardWidth / 2).round() - (deckCards.length * deckSpacing / 2).round();
    int yOffset = 0;
    for (int i = 0; i < deckCards.length; i++) {
      deckCards[i].element.style.left = "${xOffset + (i * deckSpacing)}px";
      deckCards[i].element.style.top = "$yOffset}px";
      deckCards[i].element.style.zIndex = "${i * 10}px";
    }

    deckContainer.style.width = "${(cardWidth + (deckCards.length * deckSpacing)).round()}px";
    deckContainer.style.height = "${(cardWidth * CardComponent.heightRatio).round()}px";
    pileContainer.style.width = "${cardWidth + xOffsetMaxChange * 2}px";
    pileContainer.style.height = "${cardWidth * CardComponent.heightRatio + yOffsetMaxChange * 2}px";
    changeDetectorRef.markForCheck();
  }

  static const int deckSpacing = 2;
  static const rotationMinChange = 15;
  static const rotationMaxChange = 40;
  static const xOffsetMaxChange = 25;
  static const yOffsetMaxChange = 25;
}

class CardTransformation {
  final int xOffset;
  final int yOffset;
  final int rotation;

  CardTransformation(this.xOffset, this.yOffset, this.rotation);
}
