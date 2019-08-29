import 'dart:ui' as ui;

abstract class BaseEntry {
  /** the y value */
  double y = 0;

  /** optional spot for additional data this Entry represents */
  Object mData = null;

  /** optional icon image */
  ui.Image mIcon = null;

  BaseEntry({double y, ui.Image icon, Object data}) {
    this.y = y;
    this.mIcon = icon;
    this.mData = data;
  }
}
