import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

abstract class PainterUtils {
  static TextPainter create(
      TextPainter painter, String text, Color color, double fontSize) {
    if (painter == null) {
      return _create(text, color, fontSize);
    }

    if (painter.text != null && (painter.text is TextSpan)) {
      var preText = (painter.text as TextSpan).text;
      var preColor = (painter.text as TextSpan).style.color;
      preColor = preColor == null ? ColorUtils.BLACK : preColor;
      var preFontSize = (painter.text as TextSpan).style.fontSize;
      preFontSize =
          preFontSize == null ? Utils.convertDpToPixel(13) : preFontSize;
      return _create(
          text == null ? preText : text,
          color == null ? preColor : color,
          fontSize == null ? preFontSize : fontSize);
    } else {
      return _create(text, color, fontSize);
    }
  }

  static TextPainter createWithStyle(String text, TextStyle style) {
    return TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: style));
  }

  static TextPainter _create(String text, Color color, double fontSize) {
    return TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: text, style: TextStyle(color: color, fontSize: fontSize)));
  }
}
