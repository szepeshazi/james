import 'dart:html';

import 'package:angular/angular.dart';
import 'package:james/src/models/models.dart' as m;

@Component(selector: 'card', templateUrl: 'card.html', styleUrls: ['card.css'])
class CardComponent {
  @Input()
  m.Card card;

  @Input()
  m.SeatLocation location;

  Element element;

  bool selected = false;

  CardComponent(this.element);

  void toggle() {
    selected = !selected;
    int offset = location == m.SeatLocation.south ? -20 : 20;
    element.style.transform.replaceAll(RegExp(r'translateY\(.+\)'), "");
    element.style.transform = "${element.style.transform} translateY(${selected ? offset : -offset}px)";
  }

  String get cardImageUrl => "/img/${card.rankText.toLowerCase()}_of_${card.suitText.toLowerCase()}.svg";
}
