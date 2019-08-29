import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_scatter_candle_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/bar_line_scatter_candle_bubble_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

abstract class LineScatterCandleRadarRenderer
    extends BarLineScatterCandleBubbleRenderer {
  /**
   * path that is used for drawing highlight-lines (drawLines(...) cannot be used because of dashes)
   */
  Path mHighlightLinePath = Path();

  LineScatterCandleRadarRenderer(
      ChartAnimator animator, ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler);

  /**
   * Draws vertical & horizontal highlight-lines if enabled.
   *
   * @param c
   * @param x x-position of the highlight line intersection
   * @param y y-position of the highlight line intersection
   * @param set the currently drawn dataset
   */
  void drawHighlightLines(
      Canvas c, double x, double y, ILineScatterCandleRadarDataSet set) {
    // set color and stroke-width
    mHighlightPaint
      ..color = set.getHighLightColor()
      ..strokeWidth = set.getHighlightLineWidth();

    // draw highlighted lines (if enabled)
//    mHighlightPaint.setPathEffect(set.getDashPathEffectHighlight());

    // draw vertical highlight lines
    if (set.isVerticalHighlightIndicatorEnabled()) {
      // create vertical path
      mHighlightLinePath.reset();
      mHighlightLinePath.moveTo(x, mViewPortHandler.contentTop());
      mHighlightLinePath.lineTo(x, mViewPortHandler.contentBottom());

      c.drawPath(mHighlightLinePath, mHighlightPaint);
    }

    // draw horizontal highlight lines
    if (set.isHorizontalHighlightIndicatorEnabled()) {
      // create horizontal path
      mHighlightLinePath.reset();
      mHighlightLinePath.moveTo(mViewPortHandler.contentLeft(), y);
      mHighlightLinePath.lineTo(mViewPortHandler.contentRight(), y);

      c.drawPath(mHighlightLinePath, mHighlightPaint);
    }
  }
}
