import 'package:angular/angular.dart';
import 'package:james/src/models/models.dart' as m;
import 'package:james/src/name_service.dart';
import 'package:james/src/player/player.dart';

@Component(
  selector: 'game-board',
  templateUrl: 'gameboard.html',
  styleUrls: ['gameboard.css'],
  directives: [coreDirectives, PlayerComponent],
  exports: [m.SeatLocation]

)
class GameBoardComponent implements OnInit {

  m.Game game = m.Game();

  final NameService nameService;

  GameBoardComponent(this.nameService);

  @override
  void ngOnInit() {
    List<m.Player> players = [];
    players.add(m.Player(nameService.any, false, true, m.SeatLocation.north));
    players.add(m.Player(nameService.any, false, true, m.SeatLocation.west));
    players.add(m.Player(nameService.any, false, true, m.SeatLocation.east));
    players.add(m.Player(nameService.any, true, false, m.SeatLocation.south));

    game.players = players;

    for (var i = 0; i < 5; i++) {
      for (var player in game.players) {
        player.hand.cards.add(game.deck.draw());
      }
    }
  }

}