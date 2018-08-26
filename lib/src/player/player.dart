import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:james/src/card/card.dart';
import 'package:james/src/models/models.dart' as m;

@Component(
    selector: 'player',
    templateUrl: 'player.html',
    styleUrls: ['player.css'],
    directives: [CardComponent, coreDirectives, MaterialButtonComponent],
exports: [m.SeatLocation])
class PlayerComponent {
  @Input()
  m.Player player;

  @ViewChildren('hand')
  List<CardComponent> cards;

  void arrangeCards() {
    int cardOffset = 55;
    int handOffset = (cards.length * cardOffset) ~/ 2 + cardOffset ~/ 2;
    for (int i = 0; i < cards.length; i++) {
      cards.elementAt(i).element.style.transform = "translateX(${handOffset -cardOffset * (i + 1)}px)";
      cards.elementAt(i).element.style.zIndex = "${i * 10}px";
    }
  }

  void go() {}
}
