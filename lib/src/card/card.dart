import 'dart:html';

import 'package:angular/angular.dart';
import 'package:james/src/models/models.dart' as m;

@Component(
    selector: 'card',
    templateUrl: 'card.html',
    styleUrls: ['card.css'],
    changeDetection: ChangeDetectionStrategy.OnPush)
class CardComponent {

  final ChangeDetectorRef changeDetectorRef;

  @Input()
  m.Card card;

  @Input()
  bool hide = false;

  @Input()
  m.Player player;

  Element element;

  bool _selected = false;

  bool get selected => _selected;

  @Input()
  set selected(bool newValue) {
    _selected = newValue;
    updateUi();
  }

  CardComponent(this.element, this.changeDetectorRef);

  void toggle() {
    if (!(player?.computer ?? true)) {
      selected = !selected;
    }
  }

  void updateUi() {
    int offset = player?.location == m.SeatLocation.south ? -selectedOffset : selectedOffset;
    element.style.transform.replaceAll(RegExp(r'translateY\(.+\)'), "");
    element.style.transform = "${element.style.transform} translateY(${selected ? offset : -offset}px)";
  }

  String get cardImageUrl => hide ? "/img/back_red.svg" : "/img/${card.rankText.toLowerCase()}_of_${card.suitText.toLowerCase()}.svg";

  static const int selectedOffset = 20;
  static const int viewportWidthRatio = 10;
  static const int minWidth = 42;
  static const int maxWidth = 80;
  static const double heightRatio = 1.5;
  static const double spacingRatio = 0.25;

}
