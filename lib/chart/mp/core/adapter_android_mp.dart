import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

class DashPathEffect {
  CircularIntervalList<double> _circularIntervalList;

  DashOffset _dashOffset;

  CircularIntervalList<double> get circularIntervalList =>
      _circularIntervalList;

  DashPathEffect(double lineLength, double spaceLength, double value)
      : _circularIntervalList =
            CircularIntervalList<double>(<double>[lineLength, spaceLength]),
        _dashOffset = DashOffset.absolute(value);

  Path convert2DashPath(Path path) {
    if (_circularIntervalList == null) {
      return path;
    }
    return dashPath(path,
        dashArray: _circularIntervalList, dashOffset: _dashOffset);
  }

  @override
  String toString() {
    return 'DashPathEffect{_circularIntervalList: $_circularIntervalList,\n _dashOffset: $_dashOffset}';
  }


}
