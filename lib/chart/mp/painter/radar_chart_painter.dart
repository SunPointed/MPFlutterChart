import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/src/rendering/custom_paint.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/radar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/radar_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/radar_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer_radar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer_radar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_redar_chart_painter.dart';

class RadarChartPainter extends PieRadarChartPainter<RadarData> {
  /// width of the main web lines
  double mWebLineWidth;

  /// width of the inner web lines
  double mInnerWebLineWidth;

  /// color for the main web lines
  Color mWebColor = Color.fromARGB(255, 122, 122, 122);

  /// color for the inner web
  Color mWebColorInner = Color.fromARGB(255, 122, 122, 122);

  /// transparency the grid is drawn with (0-255)
  int mWebAlpha;

  /// flag indicating if the web lines should be drawn or not
  bool mDrawWeb;

  /// modulus that determines how many labels and web-lines are skipped before the next is drawn
  int mSkipWebLineCount;

  /// the object reprsenting the y-axis labels
  YAxis mYAxis;

  YAxisRendererRadarChart mYAxisRenderer;
  XAxisRendererRadarChart mXAxisRenderer;

  RadarChartPainter(RadarData data, ChartAnimator animator,
      {double webLineWidth = 2.5,
      double innerWebLineWidth = 1.5,
      int webAlpha = 150,
      bool drawWeb = true,
      int skipWebLineCount = 0,
      double rotationAngle = 270,
      double rawRotationAngle = 270,
      bool rotateEnabled = true,
      double minOffset = 0.0,
      ViewPortHandler viewPortHandler = null,
      double maxHighlightDistance = 0.0,
      bool highLightPerTapEnabled = true,
      bool dragDecelerationEnabled = true,
      double dragDecelerationFrictionCoef = 0.9,
      double extraLeftOffset = 0.0,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      String noDataText = "No chart data available.",
      bool touchEnabled = true,
      IMarker marker = null,
      Description desc = null,
      bool drawMarkers = true,
      TextPainter infoPainter = null,
      TextPainter descPainter = null,
      IHighlighter highlighter = null,
      bool unbind = false})
      : mWebLineWidth = webLineWidth,
        mInnerWebLineWidth = innerWebLineWidth,
        mWebAlpha = webAlpha,
        mDrawWeb = drawWeb,
        mSkipWebLineCount = skipWebLineCount,
        super(data, animator,
            rotationAngle: rotationAngle,
            rawRotationAngle: rawRotationAngle,
            rotateEnabled: rotateEnabled,
            minOffset: minOffset,
            viewPortHandler: viewPortHandler,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            dragDecelerationEnabled: dragDecelerationEnabled,
            dragDecelerationFrictionCoef: dragDecelerationFrictionCoef,
            extraLeftOffset: extraLeftOffset,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            noDataText: noDataText,
            touchEnabled: touchEnabled,
            marker: marker,
            desc: desc,
            drawMarkers: drawMarkers,
            infoPainter: infoPainter,
            descPainter: descPainter,
            highlighter: highlighter,
            unbind: unbind);

  @override
  void init() {
    super.init();

    mYAxis = YAxis(position: AxisDependency.LEFT);

    mWebLineWidth = Utils.convertDpToPixel(1.5);
    mInnerWebLineWidth = Utils.convertDpToPixel(0.75);

    mRenderer = RadarChartRenderer(this, mAnimator, mViewPortHandler);
    mYAxisRenderer = YAxisRendererRadarChart(mViewPortHandler, mYAxis, this);
    mXAxisRenderer = XAxisRendererRadarChart(mViewPortHandler, mXAxis, this);

    mHighlighter = RadarHighlighter(this);
  }

  @override
  void calcMinMax() {
    super.calcMinMax();

    mYAxis.calculate(mData.getYMin2(AxisDependency.LEFT),
        mData.getYMax2(AxisDependency.LEFT));
    mXAxis.calculate(0, mData.getMaxEntryCountSet().getEntryCount().toDouble());
  }

  @override
  void calculateOffsets() {
    super.calculateOffsets();
    calcMinMax();

    mYAxisRenderer.computeAxis(
        mYAxis.mAxisMinimum, mYAxis.mAxisMaximum, mYAxis.isInverted());
    mXAxisRenderer.computeAxis(mXAxis.mAxisMinimum, mXAxis.mAxisMaximum, false);

    if (mLegend != null && !mLegend.isLegendCustom())
      mLegendRenderer.computeLegend(mData);
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    if (mData == null || mData.mDataSets == null || mData.mDataSets.length == 0)
      return;

    if (mXAxis.isEnabled())
      mXAxisRenderer.computeAxis(
          mXAxis.mAxisMinimum, mXAxis.mAxisMaximum, false);

    mXAxisRenderer.renderAxisLabels(canvas);

    if (mDrawWeb) mRenderer.drawExtras(canvas);

    if (mYAxis.isEnabled() && mYAxis.isDrawLimitLinesBehindDataEnabled())
      mYAxisRenderer.renderLimitLines(canvas);

    mRenderer.drawData(canvas);

    if (valuesToHighlight())
      mRenderer.drawHighlighted(canvas, mIndicesToHighlight);

    if (mYAxis.isEnabled() && !mYAxis.isDrawLimitLinesBehindDataEnabled())
      mYAxisRenderer.renderLimitLines(canvas);

    mYAxisRenderer.renderAxisLabels(canvas);

    mRenderer.drawValues(canvas);

    mLegendRenderer.renderLegend(canvas);

    drawDescription(canvas, size);

    drawMarkers(canvas);
  }

  /**
   * Returns the factor that is needed to transform values into pixels.
   *
   * @return
   */
  double getFactor() {
    Rect content = mViewPortHandler.getContentRect();
    return min(content.width / 2, content.height / 2) / mYAxis.mAxisRange;
  }

  /**
   * Returns the angle that each slice in the radar chart occupies.
   *
   * @return
   */
  double getSliceAngle() {
    return 360 / mData.getMaxEntryCountSet().getEntryCount();
  }

  @override
  int getIndexForAngle(double angle) {
    // take the current angle of the chart into consideration
    double a = Utils.getNormalizedAngle(angle - getRotationAngle());

    double sliceangle = getSliceAngle();

    int max = mData.getMaxEntryCountSet().getEntryCount();

    int index = 0;

    for (int i = 0; i < max; i++) {
      double referenceAngle = sliceangle * (i + 1) - sliceangle / 2;

      if (referenceAngle > a) {
        index = i;
        break;
      }
    }

    return index;
  }

  /**
   * Returns the object that represents all y-labels of the RadarChart.
   *
   * @return
   */
  YAxis getYAxis() {
    return mYAxis;
  }

  /**
   * Sets the width of the web lines that come from the center.
   *
   * @param width
   */
  void setWebLineWidth(double width) {
    mWebLineWidth = Utils.convertDpToPixel(width);
  }

  double getWebLineWidth() {
    return mWebLineWidth;
  }

  /**
   * Sets the width of the web lines that are in between the lines coming from
   * the center.
   *
   * @param width
   */
  void setWebLineWidthInner(double width) {
    mInnerWebLineWidth = Utils.convertDpToPixel(width);
  }

  double getWebLineWidthInner() {
    return mInnerWebLineWidth;
  }

  /**
   * Sets the transparency (alpha) value for all web lines, default: 150, 255
   * = 100% opaque, 0 = 100% transparent
   *
   * @param alpha
   */
  void setWebAlpha(int alpha) {
    mWebAlpha = alpha;
  }

  /**
   * Returns the alpha value for all web lines.
   *
   * @return
   */
  int getWebAlpha() {
    return mWebAlpha;
  }

  /**
   * Sets the color for the web lines that come from the center. Don't forget
   * to use getResources().getColor(...) when loading a color from the
   * resources. Default: Color.rgb(122, 122, 122)
   *
   * @param color
   */
  void setWebColor(Color color) {
    mWebColor = color;
  }

  Color getWebColor() {
    return mWebColor;
  }

  /**
   * Sets the color for the web lines in between the lines that come from the
   * center. Don't forget to use getResources().getColor(...) when loading a
   * color from the resources. Default: Color.rgb(122, 122, 122)
   *
   * @param color
   */
  void setWebColorInner(Color color) {
    mWebColorInner = color;
  }

  Color getWebColorInner() {
    return mWebColorInner;
  }

  /**
   * If set to true, drawing the web is enabled, if set to false, drawing the
   * whole web is disabled. Default: true
   *
   * @param enabled
   */
  void setDrawWeb(bool enabled) {
    mDrawWeb = enabled;
  }

  /**
   * Sets the number of web-lines that should be skipped on chart web before the
   * next one is drawn. This targets the lines that come from the center of the RadarChart.
   *
   * @param count if count = 1 -> 1 line is skipped in between
   */
  void setSkipWebLineCount(int count) {
    mSkipWebLineCount = max(0, count);
  }

  /**
   * Returns the modulus that is used for skipping web-lines.
   *
   * @return
   */
  int getSkipWebLineCount() {
    return mSkipWebLineCount;
  }

  @override
  double getRequiredLegendOffset() {
    var size = mLegendRenderer.getLabelPaint().text.style.fontSize;
    return (size == null ? Utils.convertDpToPixel(9) : size) * 4.0;
  }

  @override
  double getRequiredBaseOffset() {
    return mXAxis.isEnabled() && mXAxis.isDrawLabelsEnabled()
        ? mXAxis.mLabelRotatedWidth.toDouble()
        : Utils.convertDpToPixel(10);
  }

  @override
  double getRadius() {
    Rect content = mViewPortHandler.getContentRect();
    return min(content.width / 2, content.height / 2);
  }

  /**
   * Returns the maximum value this chart can display on it's y-axis.
   */
  double getYChartMax() {
    return mYAxis.mAxisMaximum;
  }

  /**
   * Returns the minimum value this chart can display on it's y-axis.
   */
  double getYChartMin() {
    return mYAxis.mAxisMinimum;
  }

  /**
   * Returns the range of y-values this chart can display.
   *
   * @return
   */
  double getYRange() {
    return mYAxis.mAxisRange;
  }

  @override
  ValueFormatter getDefaultValueFormatter() {
    return mDefaultValueFormatter;
  }

  @override
  void reassemble() {}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
