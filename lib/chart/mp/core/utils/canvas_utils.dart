import 'dart:ui';

abstract class CanvasUtils {
  static void drawLines(
      Canvas canvas, List<double> pts, int offset, int count, Paint paint) {
    for (int i = offset; i < count; i += 4) {
      canvas.drawLine(
          Offset(pts[i], pts[i + 1]), Offset(pts[i + 2], pts[i + 3]), paint);
    }
  }
}
