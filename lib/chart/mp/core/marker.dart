import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

import 'format.dart';

class Marker extends IMarker {
  Entry _entry;
  Highlight _highlight;
  double _dx = 0.0;
  double _dy = 0.0;

  DefaultValueFormatter _formatter;
  Color _textColor;
  Color _backColor;
  double _fontSize;

  Marker({Color textColor, Color backColor, double fontSize})
      : _textColor = textColor,
        _backColor = backColor,
        _fontSize = fontSize {
    _formatter = DefaultValueFormatter(0);
    _textColor ??= ColorUtils.PURPLE;
//    _backColor ??= Color.fromARGB((_textColor.alpha * 0.5).toInt(),
//        _textColor.red, _textColor.green, _textColor.blue);
    _backColor ??= ColorUtils.WHITE;
    _fontSize ??= 10;
  }

  @override
  void draw(Canvas canvas, double posX, double posY) {
    TextPainter painter = TextPainter(
        text: TextSpan(
            text:
                "${_formatter.getFormattedValue1(_entry.x)},${_formatter.getFormattedValue1(_entry.y)}",
            style: TextStyle(color: _textColor, fontSize: _fontSize)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    Paint paint = Paint()
      ..color = _backColor
      ..strokeWidth = 2
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    MPPointF offset = getOffsetForDrawingAtPoint(posX, posY);

    canvas.save();
    // translate to the correct position and draw
//    canvas.translate(posX + offset.x, posY + offset.y);
    painter.layout();
    var left = posX + offset.x - painter.width / 2;
    var top = posY + offset.y - painter.height / 2;
    canvas.drawRRect(
        RRect.fromLTRBR(left - 5, top - 5, left + painter.width + 5,
            top + painter.height + 5, Radius.circular(5)),
        paint);
    painter.paint(canvas, Offset(left, top));
    canvas.restore();
  }

  @override
  MPPointF getOffset() {
    return MPPointF.getInstance1(_dx, _dy);
  }

  @override
  MPPointF getOffsetForDrawingAtPoint(double posX, double posY) {
    return getOffset();
  }

  @override
  void refreshContent(Entry e, Highlight highlight) {
    _entry = e;
    _highlight = highlight;
  }
}
