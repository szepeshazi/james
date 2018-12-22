import 'dart:async';
import 'dart:html';
import 'dart:math' as math show min, max;

import 'package:angular/angular.dart';
import 'package:angular_components/utils/disposer/disposer.dart';
import 'package:james/src/card/card.dart';
import 'package:james/src/models/models.dart';

@Component(
  selector: 'deck',
  templateUrl: 'deck.html',
  styleUrls: ['deck.css'],
  directives: [coreDirectives, CardComponent],
  changeDetection: ChangeDetectionStrategy.OnPush
)
class DeckComponent implements OnInit, OnDestroy, AfterViewInit {

  final ChangeDetectorRef changeDetectorRef;
  final Disposer disposer = Disposer.oneShot();

  @Input()
  GameState gameState;

  @ViewChildren("deck")
  List<CardComponent> deckCards;

  @ViewChildren("pit")
  List<CardComponent> pitCards;

  @ViewChild("deckContainer")
  Element deckContainer;

  @ViewChild("pitContainer")
  Element pitContainer;

  DeckComponent(this.changeDetectorRef);

  List<Card> deckRepresentation;

  @override
  void ngOnInit() {
    deckRepresentation = gameState.deck.cards.skip((gameState.deck.cards.length * 9 ~/ 10) - 1).toList();
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
    deckRepresentation = gameState.deck.cards.skip((gameState.deck.cards.length * 9 ~/ 10) - 1).toList();
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

    int cardSpacing = (cardWidth * CardComponent.spacingRatio).round();
    xOffset = (cardWidth / 2).round() + (pitCards.length * cardSpacing / 2).round();
    for (int i = 0; i < pitCards.length; i++) {
      pitCards[i].element.style.left = "${xOffset + (i * cardSpacing)}px";
      pitCards[i].element.style.top = "$yOffset}px";
      pitCards[i].element.style.zIndex = "${i * 10}px";
    }

    // deckContainer.style.width = "${(cardWidth + (deckCards.length * deckSpacing)).round()}px";
    deckContainer.style.height = "${(cardWidth * CardComponent.heightRatio).round()}px";
    // pitContainer.style.width = "${(cardWidth + (pitCards.length * deckSpacing)).round()}px";
    pitContainer.style.height = "${(cardWidth * CardComponent.heightRatio).round()}px";
    changeDetectorRef.markForCheck();
  }

  static const int deckSpacing = 2;

}