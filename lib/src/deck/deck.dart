import 'dart:async';
import 'dart:html';
import 'dart:math' as math show min, max;

import 'package:angular/angular.dart';
import 'package:angular_components/utils/disposer/disposer.dart';
import 'package:james/src/card/card.dart';
import 'package:james/src/player/player.dart';
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

  @ViewChildren('deck')
  List<CardComponent> deckCards;

  @ViewChild("cardContainer")
  Element cardContainer;

  DeckComponent(this.changeDetectorRef);

  List<Card> get deckRepresentation => gameState.deck.cards.skip((gameState.deck.cards.length * 9 ~/ 10) - 1).toList();

  @override
  void ngOnInit() {
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

  arrangeCards() {
    int width = window.innerWidth ?? document.documentElement.clientWidth;
    int height = window.innerHeight ?? document.documentElement.clientHeight;
    Dimension windowSize = Dimension(width, height);
    int cardWidth = (windowSize.width * CardComponent.viewportWidthRatio / 100).round();
    cardWidth = math.max(math.min(cardWidth, CardComponent.maxWidth), CardComponent.minWidth);

    int xOffset = -(cardWidth / 2).round() - (deckCards.length * cardSpacing / 2).round();
    int yOffset = 0;

    for (int i = 0; i < deckCards.length; i++) {
      deckCards[i].element.style.left = "${xOffset + (i * cardSpacing)}px";
      deckCards[i].element.style.top = "$yOffset}px";
      deckCards[i].element.style.zIndex = "${i * 10}px";
    }

    cardContainer.style.height = "${(cardWidth * CardComponent.heightRatio).round()}px";
    changeDetectorRef.markForCheck();
  }

  static const int cardSpacing = 2;

}