import 'dart:math';

import 'package:angular/angular.dart';
import 'package:james/src/gameboard/gameboard.dart';
import 'package:james/src/name_service.dart';

@Component(
    selector: 'my-app',
    styleUrls: ['app_component.css'],
    templateUrl: 'app_component.html',
    directives: [GameBoardComponent],
    providers: [Random, NameService])
class AppComponent {}
