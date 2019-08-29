import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/default_value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class LineChartMarker implements IMarker {
  Entry entry;
  Highlight highlight;
  double dx = 0.0;
  double dy = 0.0;

  DefaultValueFormatter formatter;
  Color textColor;
  Color backColor;
  double fontSize;

  LineChartMarker({Color textColor, Color backColor, double fontSize})
      : textColor = textColor,
        backColor = backColor,
        fontSize = fontSize {
    formatter = DefaultValueFormatter(0);
    this.textColor ??= ColorUtils.PURPLE;
//    _backColor ??= Color.fromARGB((_textColor.alpha * 0.5).toInt(),
//        _textColor.red, _textColor.green, _textColor.blue);
    this.backColor ??= ColorUtils.WHITE;
    this.fontSize ??= 10;
  }

  @override
  void draw(Canvas canvas, double posX, double posY) {
    TextPainter painter = TextPainter(
        text: TextSpan(
            text:
                "${formatter.getFormattedValue1(entry.x)},${formatter.getFormattedValue1(entry.y)}",
            style: TextStyle(color: textColor, fontSize: fontSize)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    Paint paint = Paint()
      ..color = backColor
      ..strokeWidth = 2
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    MPPointF offset = getOffsetForDrawingAtPoint(posX, posY);

    canvas.save();
    // translate to the correct position and draw
//    canvas.translate(posX + offset.x, posY + offset.y);
    painter.layout();
    Offset pos = calculatePos(
        posX + offset.x, posY + offset.y, painter.width, painter.height);
    canvas.drawRRect(
        RRect.fromLTRBR(pos.dx - 5, pos.dy - 5, pos.dx + painter.width + 5,
            pos.dy + painter.height + 5, Radius.circular(5)),
        paint);
    painter.paint(canvas, pos);
    canvas.restore();
  }

  Offset calculatePos(double posX, double posY, double textW, double textH) {
    return Offset(posX - textW / 2, posY - textH / 2);
  }

  @override
  MPPointF getOffset() {
    return MPPointF.getInstance1(dx, dy);
  }

  @override
  MPPointF getOffsetForDrawingAtPoint(double posX, double posY) {
    return getOffset();
  }

  @override
  void refreshContent(Entry e, Highlight highlight) {
    entry = e;
    highlight = highlight;
  }
}
