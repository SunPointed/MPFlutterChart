import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/chart_interface.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

abstract class DataRenderer extends Renderer {
  /**
   * the animator object used to perform animations on the chart data
   */
  ChartAnimator mAnimator;

  /**
   * main paint object used for rendering
   */
  Paint mRenderPaint;

  /**
   * paint used for highlighting values
   */
  Paint mHighlightPaint;

  Paint mDrawPaint;

  TextPainter mValuePaint;

  DataRenderer(ChartAnimator animator, ViewPortHandler viewPortHandler)
      : super(viewPortHandler) {
    this.mAnimator = animator;

    mRenderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    mDrawPaint = Paint();

    mValuePaint = TextPainter(
        text: TextSpan(
            style: TextStyle(
                color: Color.fromARGB(255, 63, 63, 63),
                fontSize: Utils.convertDpToPixel(9))),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);

    mHighlightPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 255, 187, 115);
  }

  bool isDrawingValuesAllowed(ChartInterface chart) {
    return chart.getData().getEntryCount() <
        chart.getMaxVisibleCount() * mViewPortHandler.getScaleX();
  }

  /**
   * Returns the Paint object this renderer uses for drawing the values
   * (value-text).
   *
   * @return
   */
  TextPainter getPaintValues() {
    return mValuePaint;
  }

  /**
   * Returns the Paint object this renderer uses for drawing highlight
   * indicators.
   *
   * @return
   */
  Paint getPaintHighlight() {
    return mHighlightPaint;
  }

  /**
   * Returns the Paint object used for rendering.
   *
   * @return
   */
  Paint getPaintRender() {
    return mRenderPaint;
  }

  /**
   * Applies the required styling (provided by the DataSet) to the value-paint
   * object.
   *
   * @param set
   */
  void applyValueTextStyle(IDataSet set) {
    mValuePaint = TextPainter(
        text: TextSpan(
            style: set.getValueTypeface() == null
                ? TextStyle(
                    color: Color.fromARGB(255, 63, 63, 63),
                    fontSize: Utils.convertDpToPixel(9))
                : set.getValueTypeface()),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
  }

  /**
   * Initializes the buffers used for rendering with a  size. Since this
   * method performs memory allocations, it should only be called if
   * necessary.
   */
  void initBuffers();

  /**
   * Draws the actual data in form of lines, bars, ... depending on Renderer subclass.
   *
   * @param c
   */
  void drawData(Canvas c);

  /**
   * Loops over all Entrys and draws their values.
   *
   * @param c
   */
  void drawValues(Canvas c);

  /**
   * Draws the value of the given entry by using the provided IValueFormatter.
   *
   * @param c         canvas
   * @param valueText label to draw
   * @param x         position
   * @param y         position
   * @param color
   */
  void drawValue(Canvas c, String valueText, double x, double y, Color color);

  /**
   * Draws any kind of additional information (e.g. line-circles).
   *
   * @param c
   */
  void drawExtras(Canvas c);

  /**
   * Draws all highlight indicators for the values that are currently highlighted.
   *
   * @param c
   * @param indices the highlighted values
   */
  void drawHighlighted(Canvas c, List<Highlight> indices);
}
