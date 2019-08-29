import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'dart:ui' as ui;

class PieEntry extends Entry {
  String label;

  PieEntry({double value, String label, ui.Image icon, Object data})
      : super(x: 0, y: value, icon: icon, data: data) {
    this.label = label;
  }

  double getValue() {
    return y;
  }

  PieEntry copy() {
    PieEntry e = PieEntry(value: getValue(), label: label, data: mData);
    return e;
  }
}
