import 'package:angular/angular.dart';
import 'package:james/src/models/card.dart';

@Component(selector: 'card', templateUrl: 'card.html', styleUrls: ['card.css'])
class CardComponent {
  @Input()
  Card card;

  String get cardImageUrl => "/img/${card.rankText.toLowerCase()}_of_${card.suitText.toLowerCase()}.svg";
}
