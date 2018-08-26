import 'dart:async';

import 'package:angular/angular.dart';
import 'package:james/src/card/card.dart';
import 'package:james/src/models/models.dart' as m;
import 'package:james/src/name_service.dart';
import 'package:james/src/player/player.dart';

@Component(
    selector: 'game-board',
    templateUrl: 'gameboard.html',
    styleUrls: ['gameboard.css'],
    directives: [coreDirectives, PlayerComponent],
    exports: [m.SeatLocation])
class GameBoardComponent implements OnInit {
  m.Game game = m.Game();

  final NameService nameService;

  GameBoardComponent(this.nameService);

  @ViewChildren(PlayerComponent)
  List<PlayerComponent> playerComponents;

  @override
  void ngOnInit() {
    List<m.Player> players = [];
    players.add(m.Player(nameService.any, false, true, m.SeatLocation.north));
    players.add(m.Player(nameService.any, false, true, m.SeatLocation.west));
    players.add(m.Player(nameService.any, false, true, m.SeatLocation.east));
    players.add(m.Player(nameService.any, true, false, m.SeatLocation.south));

    game.players = players;
    game.play(tick);
  }

  Future tick(m.GamePhase phase, {m.Player player, List<m.Card> cards}) async {
    switch (phase) {
      case m.GamePhase.deal :
        await Future.delayed(Duration(milliseconds: animationDelays[phase]));
        for (var component in playerComponents) {
          component.arrangeCards();
        }
        break;
      case m.GamePhase.exchange:
        await Future.delayed(Duration(milliseconds: animationDelays[phase]));
        PlayerComponent component = playerComponents.firstWhere((component) => component.player == player);
        CardComponent cardComponent = component.cards.firstWhere((cardComponent) => cardComponent.card == cards.first);
        cardComponent.selected = true;
        break;
      default:
        break;
    }
  }

  static const Map<m.GamePhase, int> animationDelays = {
    m.GamePhase.shuffle: null,
    m.GamePhase.deal: 1,
    m.GamePhase.exchange: 200,
    m.GamePhase.select: 300
  };
}
