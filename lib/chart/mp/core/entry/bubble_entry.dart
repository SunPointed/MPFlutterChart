import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'dart:ui' as ui;

class BubbleEntry extends Entry {
  /// size value
  double mSize = 0;

  /// Constructor.
  ///
  /// @param x The value on the x-axis.
  /// @param y The value on the y-axis.
  /// @param size The size of the bubble.
  BubbleEntry({double x, double y, double size, Object data, ui.Image icon})
      : super(x: x, y: y, data: data, icon: icon) {
    this.mSize = size;
  }

  BubbleEntry copy() {
    BubbleEntry c = BubbleEntry(x: x, y: y, size: mSize, data: mData);
    return c;
  }

  /// Returns the size of this entry (the size of the bubble).
  ///
  /// @return
  double getSize() {
    return mSize;
  }

  void setSize(double size) {
    this.mSize = size;
  }
}
