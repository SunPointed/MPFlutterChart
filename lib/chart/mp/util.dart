import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/size.dart';

abstract class Utils {
  static void drawXAxisValue(Canvas c, String text, double x, double y,
      TextPainter paint, MPPointF anchor, double angleDegrees) {
    double drawOffsetX = 0;
    double drawOffsetY = 0;

    var originalTextAlign = paint.textAlign;
    paint.textAlign = TextAlign.left;

    if (angleDegrees != 0) {
      double translateX = x;
      double translateY = y;

      c.save();
      c.translate(translateX, translateY);
      c.rotate(angleDegrees);

      paint.text = TextSpan(text: text, style: paint.text.style);
      paint.layout();
      paint.paint(
          c, Offset(drawOffsetX - paint.width, drawOffsetY - paint.height));

      c.restore();
    } else {
      drawOffsetX += x;
      drawOffsetY += y;

      paint.text = TextSpan(text: text, style: paint.text.style);
      paint.layout();
      paint.paint(
          c, Offset(drawOffsetX - paint.width / 2, drawOffsetY - paint.height));
    }

    paint.textAlign = originalTextAlign;
  }

  static double FDEG2RAD = (pi / 180);

  static FSize getSizeOfRotatedRectangleByDegrees(
      double rectangleWidth, double rectangleHeight, double degrees) {
    final double radians = degrees * FDEG2RAD;
    return getSizeOfRotatedRectangleByRadians2(
        rectangleWidth, rectangleHeight, radians);
  }

  static FSize getSizeOfRotatedRectangleByRadians1(
      FSize rectangleSize, double radians) {
    return getSizeOfRotatedRectangleByRadians2(
        rectangleSize.width, rectangleSize.height, radians);
  }

  static FSize getSizeOfRotatedRectangleByRadians2(
      double rectangleWidth, double rectangleHeight, double radians) {
    return FSize.getInstance(
        (rectangleWidth * cos(radians)).abs() +
            (rectangleHeight * sin(radians)).abs(),
        (rectangleWidth * sin(radians)).abs() +
            (rectangleHeight * cos(radians)).abs());
  }

  static FSize calcTextSize3(TextPainter paint, String demoText) {
    FSize result = FSize.getInstance(0, 0);
    calcTextSize4(paint, demoText, result);
    return result;
  }

  static void calcTextSize4(
      TextPainter paint, String demoText, FSize outputFSize) {
    paint.text = TextSpan(text: demoText, style: paint.text.style);
    paint.layout();
    outputFSize.width = paint.width;
    outputFSize.height = paint.height;
  }

  static double nextUp(double d) {
    if (d == double.maxFinite)
      return d;
    else {
      d += 0.1;
//      todo return longBitsToDouble(doubleToRawLongBits(d) +
//          ((d >= 0.0) ? 1 : -1));
      return d;
    }
  }

  static ValueFormatter mDefaultValueFormatter =
      _generateDefaultValueFormatter();

  static ValueFormatter _generateDefaultValueFormatter() {
    return new DefaultValueFormatter(1);
  }

  static ValueFormatter getDefaultValueFormatter() {
    return mDefaultValueFormatter;
  }

  static double convertDpToPixel(double dp) {
    return dp;
  }

  static int calcTextWidth(TextPainter p, String demoText) {
    TextPainter painter = TextPainter(
        text: TextSpan(text: demoText, style: p.text.style),
        textDirection: p.textDirection,
        textAlign: p.textAlign);
    painter.layout();
    return painter.width.toInt();
  }

  static int calcTextHeight(TextPainter p, String demoText) {
    TextPainter painter = TextPainter(
        text: TextSpan(text: demoText, style: p.text.style),
        textAlign: p.textAlign,
        textDirection: p.textDirection);
    painter.layout();
    return painter.height.toInt();
  }

  static FSize calcTextSize1(TextPainter p, String demoText) {
    FSize result = FSize.getInstance(0, 0);
    calcTextSize2(p, demoText, result);
    return result;
  }

  static void calcTextSize2(TextPainter p, String demoText, FSize outputFSize) {
    TextPainter painter = TextPainter(
        text: TextSpan(text: demoText, style: p.text.style),
        textDirection: p.textDirection,
        textAlign: p.textAlign);
    painter.layout();
    outputFSize.width = painter.width;
    outputFSize.height = painter.height;
  }

  static double getLineHeight1(TextPainter paint) {
    //todo
    return getLineHeight2(paint);
  }

  static double getLineHeight2(TextPainter paint) {
    //todo
    paint.layout();
    return paint.height;
  }

  static double getLineSpacing1(TextPainter paint) {
    return getLineSpacing2(paint);
  }

  static double getLineSpacing2(TextPainter paint) {
    // todo return fontMetrics.ascent - fontMetrics.top + fontMetrics.bottom;
    paint.layout();
    return paint.height * 1.5;
  }

  static int getDecimals(double number) {
    double i = roundToNextSignificant(number);

    if (i.isInfinite) return 0;

    return (-log(i) / ln10).ceil().toInt() + 2;
  }

  static double roundToNextSignificant(double number) {
    if (number.isInfinite || number.isNaN || number == 0.0) return 0;

    final double d =
        (log(number < 0 ? -number : number) / ln10).ceil().toDouble();
    final int pw = 1 - d.toInt();
    final double magnitude = pow(10.0, pw);
    final int shifted = (number * magnitude).round();
    return shifted / magnitude;
  }
}

abstract class ColorUtils {
  static final Color GRAY = Color(0xFF999999);
  static final Color BLACK = Color(0xFF000000);
  static final Color WHITE = Color(0xFFFFFFFF);
  static final Color PURPLE = Color(0xFF512DA8);
  static final Color FADE_RED_START = Color(0x00FF0000);
  static final Color FADE_RED_END = Color(0xFFFF0000);

  static final List<Color> VORDIPLOM_COLORS = List()
    ..add(Color.fromARGB(255, 192, 255, 140))
    ..add(Color.fromARGB(255, 255, 247, 140))
    ..add(Color.fromARGB(255, 255, 208, 140))
    ..add(Color.fromARGB(255, 140, 234, 255))
    ..add(Color.fromARGB(255, 255, 140, 157));
}

abstract class Matrix4Utils {
  static void postScaleByPoint(
      Matrix4 m, double sx, double sy, double px, double py) {
    m.translate(px, py);
    m
      ..storage[15] = 1.0
      ..storage[10] = 1.0
      ..storage[13] *= sy
      ..storage[5] *= sy
      ..storage[12] *= sx
      ..storage[0] *= sx;
    m.translate(-px, -py);
  }

  static void postScale(Matrix4 m, double sx, double sy) {
    m
      ..storage[15] = 1.0
      ..storage[10] = 1.0
      ..storage[13] *= sy
      ..storage[5] *= sy
      ..storage[12] *= sx
      ..storage[0] *= sx;
  }

  static void setScaleByPoint(
      Matrix4 m, double sx, double sy, double px, double py) {
    m.translate(px, py);
    m
      ..storage[15] = 1.0
      ..storage[10] = 1.0
      ..storage[13] *= sy
      ..storage[12] *= sx
      ..storage[5] = sy
      ..storage[0] = sx;
    m.translate(-px, -py);
  }

  static void setScale(Matrix4 m, double sx, double sy) {
    m
      ..storage[13] *= sy
      ..storage[12] *= sx
      ..storage[5] = sy
      ..storage[0] = sx;
  }

  static void postTranslate(Matrix4 m, double tx, double ty) {
    final Matrix4 result = Matrix4.identity()..setTranslationRaw(tx, ty, 0.0);
    multiply(m, result).copyInto(m);
  }

  static void mapPoints(Matrix4 m, List<double> valuePoints) {
    double x = 0;
    double y = 0;
    for (int i = 0; i < valuePoints.length; i += 2) {
      x = valuePoints[i] == null ? 0 : valuePoints[i];
      y = valuePoints[i + 1] == null ? 0 : valuePoints[i + 1];
      final Vector3 transformed = m.perspectiveTransform(Vector3(x, y, 0));
      valuePoints[i] = transformed.x;
      valuePoints[i + 1] = transformed.y;
    }
  }

  static void postConcat(Matrix4 m, Matrix4 c) {
    multiply(c, m).copyInto(m);
  }

  static Matrix4 multiply(Matrix4 first, Matrix4 second) {
    var f0 = first.storage[0]; // 123
    var f1 = first.storage[4]; // 567
    var f2 = first.storage[8];
    var f3 = first.storage[12];
    var f4 = first.storage[1];
    var f5 = first.storage[5];
    var f6 = first.storage[9];
    var f7 = first.storage[13];
    var f8 = first.storage[2];
    var f9 = first.storage[6];
    var f10 = first.storage[10];
    var f11 = first.storage[14];
    var f12 = first.storage[3];
    var f13 = first.storage[7];
    var f14 = first.storage[11];
    var f15 = first.storage[15];

    var s0 = second.storage[0]; // 123
    var s1 = second.storage[4]; // 567
    var s2 = second.storage[8];
    var s3 = second.storage[12];
    var s4 = second.storage[1];
    var s5 = second.storage[5];
    var s6 = second.storage[9];
    var s7 = second.storage[13];
    var s8 = second.storage[2];
    var s9 = second.storage[6];
    var s10 = second.storage[10];
    var s11 = second.storage[14];
    var s12 = second.storage[3];
    var s13 = second.storage[7];
    var s14 = second.storage[11];
    var s15 = second.storage[15];

    Matrix4 res = Matrix4.identity();

    res.storage[0] = f0 * s0 + f1 * s4 + f2 * s8 + f3 * s12; // 123
    res.storage[4] = f0 * s1 + f1 * s5 + f2 * s9 + f3 * s13; // 567
    res.storage[8] = f0 * s2 + f1 * s6 + f2 * s10 + f3 * s14;
    res.storage[12] = f0 * s3 + f1 * s7 + f2 * s11 + f3 * s15;

    res.storage[1] = f4 * s0 + f5 * s4 + f6 * s8 + f7 * s12;
    res.storage[5] = f4 * s1 + f5 * s5 + f6 * s9 + f7 * s13;
    res.storage[9] = f4 * s2 + f5 * s6 + f6 * s10 + f7 * s14;
    res.storage[13] = f4 * s3 + f5 * s7 + f6 * s11 + f7 * s15;

    res.storage[2] = f8 * s0 + f9 * s4 + f10 * s8 + f11 * s12;
    res.storage[6] = f8 * s1 + f9 * s5 + f10 * s9 + f11 * s13;
    res.storage[10] = f8 * s2 + f9 * s6 + f10 * s10 + f11 * s14;
    res.storage[14] = f8 * s3 + f9 * s7 + f10 * s11 + f11 * s15;

    res.storage[3] = f12 * s0 + f13 * s4 + f14 * s8 + f15 * s12;
    res.storage[7] = f12 * s1 + f13 * s5 + f14 * s9 + f15 * s13;
    res.storage[11] = f12 * s2 + f13 * s6 + f14 * s10 + f15 * s14;
    res.storage[15] = f12 * s3 + f13 * s7 + f14 * s11 + f15 * s15;

    return res;
  }

  static Rect mapRect(Matrix4 m, Rect r) {
    return MatrixUtils.transformRect(m, r);
  }

  static void moveTo(Path p, Matrix4 m, Offset o) {
    o = MatrixUtils.transformPoint(m, o);
    p.moveTo(o.dx, o.dy);
  }

  static void lineTo(Path p, Matrix4 m, Offset o) {
    o = MatrixUtils.transformPoint(m, o);
    p.lineTo(o.dx, o.dy);
  }

  static void cubicTo(Path p, Matrix4 m, Offset o1, Offset o2, Offset o3) {
    o1 = MatrixUtils.transformPoint(m, o1);
    o2 = MatrixUtils.transformPoint(m, o2);
    o3 = MatrixUtils.transformPoint(m, o3);
    p.cubicTo(o1.dx, o1.dy, o2.dx, o2.dy, o3.dx, o3.dy);
  }
}

abstract class DartAdapterUtils {
  static bool equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }
}

abstract class CanvasUtils {
  static void drawLines(
      Canvas canvas, List<double> pts, int offset, int count, Paint paint) {
    for (int i = offset; i < count; i += 4) {
      canvas.drawLine(
          Offset(pts[i], pts[i + 1]), Offset(pts[i + 2], pts[i + 3]), paint);
    }
  }
}

abstract class HighlightUtils {
  static Highlight performHighlight(
      ChartPainter painter, Highlight curHighlight, Highlight lastHighlight) {
    if (curHighlight == null || curHighlight.equalTo(lastHighlight)) {
      painter.highlightValue6(null, true);
      lastHighlight = null;
    } else {
      painter.highlightValue6(curHighlight, true);
      lastHighlight = curHighlight;
    }
    return lastHighlight;
  }

  static Highlight performHighlightDrag(
      ChartPainter painter, Highlight lastHighlight, Offset offset) {
    Highlight h = painter.getHighlightByTouchPoint(offset.dx, offset.dy);

    if (h != null && !h.equalTo(lastHighlight)) {
      lastHighlight = h;
      painter.highlightValue6(h, true);
    }

    return lastHighlight;
  }
}
