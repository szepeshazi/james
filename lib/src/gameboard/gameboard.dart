import 'dart:async';

import 'package:angular/angular.dart';
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

  Future tick(m.GamePhase phase) async {
    if (animationDelays[phase] != null) {
      await Future.delayed(Duration(milliseconds: animationDelays[phase]));
      for (var component in playerComponents) {
        component.arrangeCards();
      }
    }
  }

  static const Map<m.GamePhase, int> animationDelays = {
    m.GamePhase.shuffle: null,
    m.GamePhase.deal: null,
    m.GamePhase.exchange: 100,
    m.GamePhase.select: 300
  };
}
