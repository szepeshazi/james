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
    exports: [m.SeatLocation],
    changeDetection: ChangeDetectionStrategy.OnPush)
class GameBoardComponent implements OnInit {
  m.Game game = m.Game();

  final NameService nameService;

  final ChangeDetectorRef changeDetectorRef;

  GameBoardComponent(this.nameService, this.changeDetectorRef);

  @ViewChildren(PlayerComponent)
  List<PlayerComponent> playerComponents;

  Completer<List<m.Card>> exchangeCompleter;

  @override
  void ngOnInit() {
    List<m.Player> players = [];
    players.add(m.Player.ai(nameService.any, false, m.SeatLocation.north));
    players.add(m.Player.ai(nameService.any, false, m.SeatLocation.west));
    players.add(m.Player.ai(nameService.any, false, m.SeatLocation.east));
    players.add(m.Player.human(nameService.any, true, m.SeatLocation.south));

    game.players = players;
    game.play(uiCallback);
  }

  Future<List<m.Card>> uiCallback(m.GamePhase phase, {m.Player player, List<m.Card> cards}) async {
    switch (phase) {
      case m.GamePhase.deal:
        await Future.delayed(Duration(milliseconds: animationDelays[phase]));
        for (var component in playerComponents) {
          component.arrangeCards();
        }
        break;
      case m.GamePhase.exchange:
        if (player.self) {
          exchangeCompleter = Completer<List<m.Card>>();
          print("exchangeCompleter init");
          return exchangeCompleter.future;
        } else {
          await Future.delayed(Duration(milliseconds: animationDelays[phase]));
          PlayerComponent component = playerComponents.firstWhere((component) => component.player == player);
          component.cards
              .where((cardComponent) => cards.any((card) => cardComponent.card == card))
              .forEach((cardComponent) => cardComponent.selected = true);
          CardComponent cardComponent =
              component.cards.firstWhere((cardComponent) => cardComponent.card == cards.first);
          cardComponent.selected = true;
          return Future.value([cardComponent.card]);
        }
        break;
      default:
        break;
    }
    return null;
  }

  void cardsSelected(List<m.Card> cards) {
    print("exchangeCompleter complete: $exchangeCompleter");
    exchangeCompleter.complete(cards);
  }

  static const Map<m.GamePhase, int> animationDelays = {
    m.GamePhase.shuffle: null,
    m.GamePhase.deal: 1,
    m.GamePhase.exchange: 200,
    m.GamePhase.select: 300
  };
}
