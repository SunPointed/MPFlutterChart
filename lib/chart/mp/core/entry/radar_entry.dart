import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';

class RadarEntry extends Entry {
  RadarEntry({double value, Object data}) : super(x: 0, y: value, data: data);

  /**
   * This is the same as getY(). Returns the value of the RadarEntry.
   *
   * @return
   */
  double getValue() {
    return y;
  }

  RadarEntry copy() {
    RadarEntry e = RadarEntry(value: y, data: mData);
    return e;
  }
}
