import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:james/src/deck/deck.dart';
import 'package:james/src/models/models.dart' as m;
import 'package:james/src/name_service.dart';
import 'package:james/src/player/player.dart';

@Component(
    selector: 'game-board',
    templateUrl: 'gameboard.html',
    styleUrls: ['gameboard.css'],
    directives: [coreDirectives, PlayerComponent, DeckComponent],
    exports: [m.SeatLocation],
    changeDetection: ChangeDetectionStrategy.OnPush)
class GameBoardComponent implements OnInit, AfterViewInit {
  m.Game game = m.Game();

  final NameService nameService;

  final ChangeDetectorRef changeDetectorRef;

  GameBoardComponent(this.nameService, this.changeDetectorRef);

  @ViewChildren(PlayerComponent)
  List<PlayerComponent> playerComponents;

  Completer<List<m.Card>> selectionCompleter;

  @override
  void ngOnInit() {
    List<m.Player> players = [];
    players.add(m.Player.ai(nameService.any, false, m.SeatLocation.north));
    players.add(m.Player.ai(nameService.any, false, m.SeatLocation.west));
    players.add(m.Player.ai(nameService.any, false, m.SeatLocation.east));
    players.add(m.Player.human(nameService.any, true, m.SeatLocation.south));

    game.log.entries.last.players = players;
  }

  @override
  void ngAfterViewInit() {
    game.play(uiCallback);
  }

  Future<List<m.Card>> uiCallback(m.Phase phase,
      {m.Player player, List<m.Card> cards, Map<m.CallbackParam, dynamic> params}) async {
    PlayerComponent currentPlayerComponent =
        player == null ? null : playerComponents.firstWhere((component) => component.player == player);
    switch (phase) {
      case m.Phase.beforeDeal:
        currentPlayerComponent.numOfCards = params[m.CallbackParam.cardsToDeal];
        break;
      case m.Phase.deal:
        await updatePlayerHand(currentPlayerComponent);
        await Future.delayed(animationDelays[Delay.short]);
        break;
      case m.Phase.afterDeal:
        await updatePlayerHand(currentPlayerComponent);
        await Future.delayed(animationDelays[Delay.medium]);
        break;
      case m.Phase.exchange:
        if (player.self) {
          selectionCompleter = Completer<List<m.Card>>();
          return selectionCompleter.future;
        } else {
          currentPlayerComponent.cards
              .where((cardComponent) => cards.any((card) => cardComponent.card == card))
              .forEach((cardComponent) => cardComponent.selected = true);
          await updatePlayerHand(currentPlayerComponent);
          await Future.delayed(animationDelays[Delay.long]);
          return Future.value(cards);
        }
        break;
      case m.Phase.replaced:
        await updatePlayerHand(currentPlayerComponent);
        await Future.delayed(animationDelays[Delay.medium]);
        break;
      case m.Phase.afterExchange:
        await updatePlayerHand(currentPlayerComponent);
        await Future.delayed(animationDelays[Delay.medium]);
        break;
      case m.Phase.playHand:
        if (player.self) {
          selectionCompleter = Completer<List<m.Card>>();
          return selectionCompleter.future;
        } else {
          currentPlayerComponent.cards
              .where((cardComponent) => cards.any((card) => cardComponent.card == card))
              .forEach((cardComponent) => cardComponent.selected = true);
          await updatePlayerHand(currentPlayerComponent);
          await Future.delayed(animationDelays[Delay.long]);
          return Future.value(cards);
        }
        break;
      case m.Phase.afterPlayHand:
        game.log = game.log.clone();
        await updatePlayerHand(currentPlayerComponent);
        await Future.delayed(animationDelays[Delay.medium]);
        break;
      default:
        break;
    }
    return null;
  }

  Future updatePlayerHand(PlayerComponent playerComponent) async {
    playerComponent.changeDetectorRef.markForCheck();
    await window.animationFrame;
    playerComponent.arrangeCards();
  }

  void cardsSelected(List<m.Card> cards) {
    selectionCompleter.complete(cards);
  }

  static const Map<Delay, Duration> animationDelays = {
    Delay.short: Duration(milliseconds: 50),
    Delay.medium: Duration(milliseconds: 300),
    Delay.long : Duration(seconds: 1)
  };

}

enum Delay {
  short,
  medium,
  long
}
