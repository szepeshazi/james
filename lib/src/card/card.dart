import 'package:angular/angular.dart';
import 'package:james/src/models/card.dart';

@Component(selector: 'card', template: '<img [src]="cardImageUrl">')
class CardComponent {
  @Input()
  Card card;

  String get cardImageUrl => "/img/${card.rankText.toLowerCase()}_of_${card.suitText.toLowerCase()}.svg";
}
