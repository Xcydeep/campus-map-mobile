import 'coordinate.dart';

class MapRoute {
  final List<Coordinate> coordinates;
  final List<dynamic>? steps;

  MapRoute({required this.coordinates, this.steps});
}
