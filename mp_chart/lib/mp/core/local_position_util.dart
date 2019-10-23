import 'package:flutter/widgets.dart';

class LocalPositionUtil {
  static Offset getLocalPosition(Offset globalPosition, BuildContext context) {
    RenderBox getBox = context.findRenderObject() as RenderBox;
    return getBox.globalToLocal(globalPosition);
  }
}
