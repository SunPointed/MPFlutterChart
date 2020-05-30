import 'package:flutter/painting.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/render/line_scatter_candle_radar_renderer.dart';
import 'package:mp_chart/mp/core/view_port.dart';

abstract class LineRadarRenderer extends LineScatterCandleRadarRenderer {
  LineRadarRenderer(Animator animator, ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler);

  /// Draws the provided path in filled mode with the provided drawable.
  ///
  /// @param c
  /// @param filledPath
  /// @param drawable
//  void drawFilledPath1(Canvas c, Path filledPath, ui.Image drawable) {
//    if (clipPathSupported()) {
//      c.save();
//      c.clipPath(filledPath);
//      drawable.setBounds((int) mViewPortHandler.contentLeft(),
//    (int) mViewPortHandler.contentTop(),
//    (int) mViewPortHandler.contentRight(),
//    (int) mViewPortHandler.contentBottom());
//    drawable.draw(c);
//      c.drawImage(drawable, Offset(0, 0), drawPaint);
//
//      c.restore();
//    }
//    else {
//    throw Exception("Fill-drawables not (yet) supported below API level 18, " +
//    "this code was run on API level " + Utils.getSDKInt() + ".");
//    }
//  }

  /// Draws the provided path in filled mode with the provided color and alpha.
  /// Special thanks to Angelo Suzuki (https://github.com/tinsukE) for this.
  ///
  /// @param c
  /// @param filledPath
  /// @param fillColor
  /// @param fillAlpha
  void drawFilledPath2(
      Canvas c, Path filledPath, int fillColor, int fillAlpha) {
    int color = (fillAlpha << 24) | (fillColor & 0xffffff);

//    if (clipPathSupported()) {
//      c.save();
//      c.clipPath(filledPath);
//      c.drawColor(Color(color), BlendMode.srcOver);
//      c.restore();
//    } else {
    // save
      var previous = renderPaint.style;
      Color previousColor = renderPaint.color;

      // set
      renderPaint
        ..style = PaintingStyle.fill
        ..color = Color(color);

      c.drawPath(filledPath, renderPaint);

      // restore
      renderPaint
        ..style = previous
        ..color = previousColor;
//    }
  }

  void drawFilledPath3(
      Canvas c, Path filledPath, int startColor, int endColor, int fillAlpha) {
    int sc = (fillAlpha << 24) | (startColor & 0xffffff);
    int ec = (fillAlpha << 24) | (endColor & 0xffffff);

//    if (clipPathSupported()) {
//      c.save();
//      c.clipPath(filledPath);
//      c.drawColor(Color(color), BlendMode.srcOver);
//      c.restore();
//    } else {
      // save
      var previous = renderPaint.style;
      Color previousColor = renderPaint.color;

      final Gradient gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(sc), Color(ec)],
      );
      Rect bounds = filledPath.getBounds();
      // set
      renderPaint
        ..style = PaintingStyle.fill
        ..shader = gradient.createShader(Rect.fromLTWH(
          bounds.left,
          bounds.top,
          bounds.width,
          bounds.height,
        ));

      c.drawPath(filledPath, renderPaint);

      // restore
      renderPaint
        ..style = previous
        ..color = previousColor;
//    }
  }

  /// Clip path with hardware acceleration only working properly on API level 18 and above.
  ///
  /// @return
//  bool clipPathSupported() {
//    return false;
//  }
}
