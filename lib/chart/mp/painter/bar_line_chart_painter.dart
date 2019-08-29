import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_line_scatter_candle_bubble_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bar_line_scatter_candle_bubble_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/chart_hightlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

abstract class BarLineChartBasePainter<
        T extends BarLineScatterCandleBubbleData<
            IBarLineScatterCandleBubbleDataSet<Entry>>> extends ChartPainter<T>
    implements BarLineScatterCandleBubbleDataProvider {
  /**
   * the maximum number of entries to which values will be drawn
   * (entry numbers greater than this value will cause value-labels to disappear)
   */
  int mMaxVisibleCount = 100;

  /**
   * flag that indicates if auto scaling on the y axis is enabled
   */
  bool mAutoScaleMinMaxEnabled = false;

  /**
   * flag that indicates if pinch-zoom is enabled. if true, both x and y axis
   * can be scaled with 2 fingers, if false, x and y axis can be scaled
   * separately
   */
  bool mPinchZoomEnabled = false;

  /**
   * flag that indicates if double tap zoom is enabled or not
   */
  bool mDoubleTapToZoomEnabled = true;

  /**
   * flag that indicates if highlighting per dragging over a fully zoomed out
   * chart is enabled
   */
  bool mHighlightPerDragEnabled = true;

  /**
   * if true, dragging is enabled for the chart
   */
  bool mDragXEnabled = true;
  bool mDragYEnabled = true;

  bool mScaleXEnabled = true;
  bool mScaleYEnabled = true;

  /**
   * paint object for the (by default) lightgrey background of the grid
   */
  Paint mGridBackgroundPaint;

  Paint mBorderPaint;

  /**
   * flag indicating if the grid background should be drawn or not
   */
  bool mDrawGridBackground = false;

  bool mDrawBorders = false;

  bool mClipValuesToContent = false;

  /**
   * Sets the minimum offset (padding) around the chart, defaults to 15
   */
  double mMinOffset = 20;

  /**
   * flag indicating if the chart should stay at the same position after a rotation. Default is false.
   */
  bool mKeepPositionOnRotation = false;

  /**
   * the listener for user drawing on the chart
   */
  OnDrawListener mDrawListener;

  /**
   * the object representing the labels on the left y-axis
   */
  YAxis mAxisLeft;

  /**
   * the object representing the labels on the right y-axis
   */
  YAxis mAxisRight;

  YAxisRenderer mAxisRendererLeft;
  YAxisRenderer mAxisRendererRight;

  Transformer mLeftAxisTransformer;
  Transformer mRightAxisTransformer;

  XAxisRenderer mXAxisRenderer;

  /**
   * flag that indicates if a custom viewport offset has been set
   */
  bool mCustomViewPortEnabled = false;

  BarLineChartBasePainter(T data,
      {ViewPortHandler viewPortHandler = null,
      ChartAnimator animator = null,
      Transformer leftAxisTransformer = null,
      Transformer rightAxisTransformer = null,
      Matrix4 zoomMatrixBuffer = null,
      Color backgroundColor = null,
      Color borderColor = null,
      double borderStrokeWidth = 1.0,
      bool keepPositionOnRotation = false,
      bool pinchZoomEnabled = false,
      XAxisRenderer xAxisRenderer = null,
      YAxisRenderer rendererLeftYAxis = null,
      YAxisRenderer rendererRightYAxis = null,
      bool autoScaleMinMaxEnabled = false,
      double minOffset = 15,
      bool clipValuesToContent = false,
      bool drawBorders = false,
      bool drawGridBackground = false,
      bool doubleTapToZoomEnabled = true,
      bool scaleXEnabled = true,
      bool scaleYEnabled = true,
      bool dragXEnabled = true,
      bool dragYEnabled = true,
      bool highlightPerDragEnabled = true,
      int maxVisibleCount = 100,
      OnDrawListener drawListener = null,
      double minXRange = 1.0,
      double maxXRange = 1.0,
      double minimumScaleX = 1.0,
      double minimumScaleY = 1.0,
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
      : mKeepPositionOnRotation = keepPositionOnRotation,
        mLeftAxisTransformer = leftAxisTransformer,
        mRightAxisTransformer = rightAxisTransformer,
        mZoomMatrixBuffer = zoomMatrixBuffer,
        mPinchZoomEnabled = pinchZoomEnabled,
        mXAxisRenderer = xAxisRenderer,
        mAxisRendererLeft = rendererLeftYAxis,
        mAxisRendererRight = rendererRightYAxis,
        mAutoScaleMinMaxEnabled = autoScaleMinMaxEnabled,
        mMinOffset = minOffset,
        mClipValuesToContent = clipValuesToContent,
        mDrawBorders = drawBorders,
        mDrawGridBackground = drawGridBackground,
        mDoubleTapToZoomEnabled = doubleTapToZoomEnabled,
        mScaleXEnabled = scaleXEnabled,
        mScaleYEnabled = scaleYEnabled,
        mDragXEnabled = dragXEnabled,
        mDragYEnabled = dragYEnabled,
        mHighlightPerDragEnabled = highlightPerDragEnabled,
        mMaxVisibleCount = maxVisibleCount,
        mDrawListener = drawListener,
        super(data,
            viewPortHandler: viewPortHandler,
            animator: animator,
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
            unbind: unbind) {
    double minXScale = mXAxis.mAxisRange / (minXRange);
    mViewPortHandler.setMaximumScaleX(minXScale);
    double maxXScale = mXAxis.mAxisRange / (maxXRange);
    mViewPortHandler.setMinimumScaleX(maxXScale);
    mViewPortHandler.setMinimumScaleX(minimumScaleX);
    mViewPortHandler.setMinimumScaleY(minimumScaleY);

    mGridBackgroundPaint = Paint()
      ..color = backgroundColor == null
          ? Color.fromARGB(255, 240, 240, 240)
          : backgroundColor
      ..style = PaintingStyle.fill;
    // grey

    mBorderPaint = Paint()
      ..color = borderColor == null ? ColorUtils.BLACK : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = Utils.convertDpToPixel(borderStrokeWidth);
  }

  @override
  void init() {
    super.init();
    mAxisLeft = YAxis(position: AxisDependency.LEFT);
    mAxisRight = YAxis(position: AxisDependency.RIGHT);

    mLeftAxisTransformer ??= Transformer(mViewPortHandler);
    mRightAxisTransformer ??= Transformer(mViewPortHandler);
    mZoomMatrixBuffer ??= Matrix4.identity();

    mAxisRendererLeft ??=
        YAxisRenderer(mViewPortHandler, mAxisLeft, mLeftAxisTransformer);
    mAxisRendererRight ??=
        YAxisRenderer(mViewPortHandler, mAxisRight, mRightAxisTransformer);
    mXAxisRenderer ??=
        XAxisRenderer(mViewPortHandler, mXAxis, mLeftAxisTransformer);

    mHighlighter = ChartHighlighter(this);
  }

  @override
  ValueFormatter getDefaultValueFormatter() {
    return mDefaultValueFormatter;
  }

  @override
  int getMaxVisibleCount() {
    return mMaxVisibleCount;
  }

  @override
  void reassemble() {
    mOffsetsCalculated = false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    if (mData == null) return;

    // execute all drawing commands
    drawGridBackground(canvas);

    if (mAutoScaleMinMaxEnabled) {
      autoScale();
    }

    if (mAxisLeft.isEnabled())
      mAxisRendererLeft.computeAxis(mAxisLeft.mAxisMinimum,
          mAxisLeft.mAxisMaximum, mAxisLeft.isInverted());

    if (mAxisRight.isEnabled())
      mAxisRendererRight.computeAxis(mAxisRight.mAxisMinimum,
          mAxisRight.mAxisMaximum, mAxisRight.isInverted());
    if (mXAxis.isEnabled())
      mXAxisRenderer.computeAxis(
          mXAxis.mAxisMinimum, mXAxis.mAxisMaximum, false);

    mXAxisRenderer.renderAxisLine(canvas);
    mAxisRendererLeft.renderAxisLine(canvas);
    mAxisRendererRight.renderAxisLine(canvas);

    if (mXAxis.isDrawGridLinesBehindDataEnabled())
      mXAxisRenderer.renderGridLines(canvas);

    if (mAxisLeft.isDrawGridLinesBehindDataEnabled())
      mAxisRendererLeft.renderGridLines(canvas);

    if (mAxisRight.isDrawGridLinesBehindDataEnabled())
      mAxisRendererRight.renderGridLines(canvas);

    if (mXAxis.isEnabled() && mXAxis.isDrawLimitLinesBehindDataEnabled())
      mXAxisRenderer.renderLimitLines(canvas);

    if (mAxisLeft.isEnabled() && mAxisLeft.isDrawLimitLinesBehindDataEnabled())
      mAxisRendererLeft.renderLimitLines(canvas);

    if (mAxisRight.isEnabled() &&
        mAxisRight.isDrawLimitLinesBehindDataEnabled())
      mAxisRendererRight.renderLimitLines(canvas);

    // make sure the data cannot be drawn outside the content-rect
    canvas.save();
    canvas.clipRect(mViewPortHandler.getContentRect());

    mRenderer.drawData(canvas);

    if (!mXAxis.isDrawGridLinesBehindDataEnabled())
      mXAxisRenderer.renderGridLines(canvas);

    if (!mAxisLeft.isDrawGridLinesBehindDataEnabled())
      mAxisRendererLeft.renderGridLines(canvas);

    if (!mAxisRight.isDrawGridLinesBehindDataEnabled())
      mAxisRendererRight.renderGridLines(canvas);

    // if highlighting is enabled
    if (valuesToHighlight())
      mRenderer.drawHighlighted(canvas, mIndicesToHighlight);

    // Removes clipping rectangle
    canvas.restore();

    mRenderer.drawExtras(canvas);

    if (mXAxis.isEnabled() && !mXAxis.isDrawLimitLinesBehindDataEnabled())
      mXAxisRenderer.renderLimitLines(canvas);

    if (mAxisLeft.isEnabled() && !mAxisLeft.isDrawLimitLinesBehindDataEnabled())
      mAxisRendererLeft.renderLimitLines(canvas);

    if (mAxisRight.isEnabled() &&
        !mAxisRight.isDrawLimitLinesBehindDataEnabled())
      mAxisRendererRight.renderLimitLines(canvas);

    mXAxisRenderer.renderAxisLabels(canvas);
    mAxisRendererLeft.renderAxisLabels(canvas);
    mAxisRendererRight.renderAxisLabels(canvas);

    if (mClipValuesToContent) {
      canvas.save();
      canvas.clipRect(mViewPortHandler.getContentRect());

      mRenderer.drawValues(canvas);

      canvas.restore();
    } else {
      mRenderer.drawValues(canvas);
    }

    mLegendRenderer.renderLegend(canvas);

    drawDescription(canvas, size);

    drawMarkers(canvas);
  }

  void prepareValuePxMatrix() {
    mRightAxisTransformer.prepareMatrixValuePx(mXAxis.mAxisMinimum,
        mXAxis.mAxisRange, mAxisRight.mAxisRange, mAxisRight.mAxisMinimum);

    mLeftAxisTransformer.prepareMatrixValuePx(mXAxis.mAxisMinimum,
        mXAxis.mAxisRange, mAxisLeft.mAxisRange, mAxisLeft.mAxisMinimum);
  }

  void prepareOffsetMatrix() {
    mRightAxisTransformer.prepareMatrixOffset(mAxisRight.isInverted());
    mLeftAxisTransformer.prepareMatrixOffset(mAxisLeft.isInverted());
  }

  /**
   * Performs auto scaling of the axis by recalculating the minimum and maximum y-values based on the entries currently in view.
   */
  void autoScale() {
//    final double fromX = getLowestVisibleX();
//    final double toX = getHighestVisibleX();
//
//    mData.calcMinMaxY(fromX, toX);
//
//    mXAxis.calculate(mData.getXMin(), mData.getXMax());
//
//    // calculate axis range (min / max) according to provided data
//
//    if (mAxisLeft.isEnabled())
//      mAxisLeft.calculate(mData.getYMin2(AxisDependency.LEFT),
//          mData.getYMax2(AxisDependency.LEFT));
//
//    if (mAxisRight.isEnabled())
//      mAxisRight.calculate(mData.getYMin2(AxisDependency.RIGHT),
//          mData.getYMax2(AxisDependency.RIGHT));
//
//    calculateOffsets();
  }

  @override
  void calcMinMax() {
    mXAxis.calculate(mData.getXMin(), mData.getXMax());
    // calculate axis range (min / max) according to provided data
    mAxisLeft.calculate(mData.getYMin2(AxisDependency.LEFT),
        mData.getYMax2(AxisDependency.LEFT));
    mAxisRight.calculate(mData.getYMin2(AxisDependency.RIGHT),
        mData.getYMax2(AxisDependency.RIGHT));
  }

  Rect calculateLegendOffsets(Rect offsets) {
    offsets = Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    // setup offsets for legend
    if (mLegend != null &&
        mLegend.isEnabled() &&
        !mLegend.isDrawInsideEnabled()) {
      switch (mLegend.getOrientation()) {
        case LegendOrientation.VERTICAL:
          switch (mLegend.getHorizontalAlignment()) {
            case LegendHorizontalAlignment.LEFT:
              offsets = Rect.fromLTRB(
                  min(
                          mLegend.mNeededWidth,
                          mViewPortHandler.getChartWidth() *
                              mLegend.getMaxSizePercent()) +
                      mLegend.getXOffset(),
                  0.0,
                  0.0,
                  0.0);
              break;

            case LegendHorizontalAlignment.RIGHT:
              offsets = Rect.fromLTRB(
                  0.0,
                  0.0,
                  min(
                          mLegend.mNeededWidth,
                          mViewPortHandler.getChartWidth() *
                              mLegend.getMaxSizePercent()) +
                      mLegend.getXOffset(),
                  0.0);
              break;

            case LegendHorizontalAlignment.CENTER:
              switch (mLegend.getVerticalAlignment()) {
                case LegendVerticalAlignment.TOP:
                  offsets = Rect.fromLTRB(
                      0.0,
                      min(
                              mLegend.mNeededHeight,
                              mViewPortHandler.getChartHeight() *
                                  mLegend.getMaxSizePercent()) +
                          mLegend.getYOffset(),
                      0.0,
                      0.0);
                  break;

                case LegendVerticalAlignment.BOTTOM:
                  offsets = Rect.fromLTRB(
                      0.0,
                      0.0,
                      0.0,
                      min(
                              mLegend.mNeededHeight,
                              mViewPortHandler.getChartHeight() *
                                  mLegend.getMaxSizePercent()) +
                          mLegend.getYOffset());
                  break;

                default:
                  break;
              }
          }

          break;

        case LegendOrientation.HORIZONTAL:
          switch (mLegend.getVerticalAlignment()) {
            case LegendVerticalAlignment.TOP:
              offsets = Rect.fromLTRB(
                  0.0,
                  min(
                          mLegend.mNeededHeight,
                          mViewPortHandler.getChartHeight() *
                              mLegend.getMaxSizePercent()) +
                      mLegend.getYOffset(),
                  0.0,
                  0.0);
              break;

            case LegendVerticalAlignment.BOTTOM:
              offsets = Rect.fromLTRB(
                  0.0,
                  0.0,
                  0.0,
                  min(
                          mLegend.mNeededHeight,
                          mViewPortHandler.getChartHeight() *
                              mLegend.getMaxSizePercent()) +
                      mLegend.getYOffset());
              break;

            default:
              break;
          }
          break;
      }
    }
    return offsets;
  }

  Rect mOffsetsBuffer = Rect.zero;

  @override
  void calculateOffsets() {
    if (mLegend != null) mLegendRenderer.computeLegend(mData);
    mRenderer?.initBuffers();
    calcMinMax();
    if (!mCustomViewPortEnabled) {
      double offsetLeft = 0, offsetRight = 0, offsetTop = 0, offsetBottom = 0;

      mOffsetsBuffer = calculateLegendOffsets(mOffsetsBuffer);

      offsetLeft += mOffsetsBuffer.left;
      offsetTop += mOffsetsBuffer.top;
      offsetRight += mOffsetsBuffer.right;
      offsetBottom += mOffsetsBuffer.bottom;

      // offsets for y-labels
      if (mAxisLeft.needsOffset()) {
        offsetLeft += mAxisLeft
            .getRequiredWidthSpace(mAxisRendererLeft.getPaintAxisLabels());
      }

      if (mAxisRight.needsOffset()) {
        offsetRight += mAxisRight
            .getRequiredWidthSpace(mAxisRendererRight.getPaintAxisLabels());
      }

      if (mXAxis.isEnabled() && mXAxis.isDrawLabelsEnabled()) {
        double xLabelHeight = mXAxis.mLabelRotatedHeight + mXAxis.getYOffset();

        // offsets for x-labels
        if (mXAxis.getPosition() == XAxisPosition.BOTTOM) {
          offsetBottom += xLabelHeight;
        } else if (mXAxis.getPosition() == XAxisPosition.TOP) {
          offsetTop += xLabelHeight;
        } else if (mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
          offsetBottom += xLabelHeight;
          offsetTop += xLabelHeight;
        }
      }

      offsetTop += mExtraTopOffset;
      offsetRight += mExtraRightOffset;
      offsetBottom += mExtraBottomOffset;
      offsetLeft += mExtraLeftOffset;

      double minOffset = Utils.convertDpToPixel(mMinOffset);

      mViewPortHandler.restrainViewPort(
          max(minOffset, offsetLeft),
          max(minOffset, offsetTop),
          max(minOffset, offsetRight),
          max(minOffset, offsetBottom));

//    if (mLogEnabled) {
//    Log.i(LOG_TAG, "offsetLeft: " + offsetLeft + ", offsetTop: " + offsetTop
//    + ", offsetRight: " + offsetRight + ", offsetBottom: " + offsetBottom);
//    Log.i(LOG_TAG, "Content: " + mViewPortHandler.getContentRect().toString());
//    }
    }

    prepareOffsetMatrix();
    prepareValuePxMatrix();
  }

  /**
   * draws the grid background
   */
  void drawGridBackground(Canvas c) {
    if (mDrawGridBackground) {
      // draw the grid background
      c.drawRect(mViewPortHandler.getContentRect(), mGridBackgroundPaint);
    }

    if (mDrawBorders) {
      c.drawRect(mViewPortHandler.getContentRect(), mBorderPaint);
    }
  }

  /**
   * Returns the Transformer class that contains all matrices and is
   * responsible for transforming values into pixels on the screen and
   * backwards.
   *
   * @return
   */
  Transformer getTransformer(AxisDependency which) {
    if (which == AxisDependency.LEFT)
      return mLeftAxisTransformer;
    else
      return mRightAxisTransformer;
  }

  /**
   * ################ ################ ################ ################
   */
  /**
   * CODE BELOW THIS RELATED TO SCALING AND GESTURES AND MODIFICATION OF THE
   * VIEWPORT
   */
  Matrix4 mZoomMatrixBuffer;

  // todo zoom
//  /**
//   * Zooms in by 1.4f, into the charts center.
//   */
//   void zoomIn() {
//
//    MPPointF center = mViewPortHandler.getContentCenter();
//
//    mViewPortHandler.zoomIn(center.x, -center.y, mZoomMatrixBuffer);
//    mViewPortHandler.refresh(mZoomMatrixBuffer, this, false);
//
//    MPPointF.recycleInstance(center);
//
//    // Range might have changed, which means that Y-axis labels
//    // could have changed in size, affecting Y-axis size.
//    // So we need to recalculate offsets.
//    calculateOffsets();
//    postInvalidate();
//  }
//
//  /**
//   * Zooms out by 0.7f, from the charts center.
//   */
//   void zoomOut() {
//
//    MPPointF center = mViewPortHandler.getContentCenter();
//
//    mViewPortHandler.zoomOut(center.x, -center.y, mZoomMatrixBuffer);
//    mViewPortHandler.refresh(mZoomMatrixBuffer, this, false);
//
//    MPPointF.recycleInstance(center);
//
//    // Range might have changed, which means that Y-axis labels
//    // could have changed in size, affecting Y-axis size.
//    // So we need to recalculate offsets.
//    calculateOffsets();
//    postInvalidate();
//  }
//
//  /**
//   * Zooms out to original size.
//   */
//   void resetZoom() {
//
//    mViewPortHandler.resetZoom(mZoomMatrixBuffer);
//    mViewPortHandler.refresh(mZoomMatrixBuffer, this, false);
//
//    // Range might have changed, which means that Y-axis labels
//    // could have changed in size, affecting Y-axis size.
//    // So we need to recalculate offsets.
//    calculateOffsets();
//    postInvalidate();
//  }

  /**
   * Zooms in or out by the given scale factor. x and y are the coordinates
   * (in pixels) of the zoom center.
   *
   * @param scaleX if < 1f --> zoom out, if > 1f --> zoom in
   * @param scaleY if < 1f --> zoom out, if > 1f --> zoom in
   * @param x
   * @param y
   */
  void zoom(double scaleX, double scaleY, double x, double y) {
    mViewPortHandler.zoom4(scaleX, scaleY, x, -y, mZoomMatrixBuffer);
    mViewPortHandler.refresh(mZoomMatrixBuffer);
  }

  void translate(double dx, double dy) {
    Matrix4Utils.postTranslate(mViewPortHandler.mMatrixTouch, dx, dy);
    mViewPortHandler.limitTransAndScale(
        mViewPortHandler.mMatrixTouch, mViewPortHandler.mContentRect);
  }

//
//  /**
//   * Zooms in or out by the given scale factor.
//   * x and y are the values (NOT PIXELS) of the zoom center..
//   *
//   * @param scaleX
//   * @param scaleY
//   * @param xValue
//   * @param yValue
//   * @param axis   the axis relative to which the zoom should take place
//   */
//   void zoom(double scaleX, double scaleY, double xValue, double yValue, AxisDependency axis) {
//
//    Runnable job = ZoomJob.getInstance(mViewPortHandler, scaleX, scaleY, xValue, yValue, getTransformer(axis), axis, this);
//    addViewportJob(job);
//  }
//
//  /**
//   * Zooms to the center of the chart with the given scale factor.
//   *
//   * @param scaleX
//   * @param scaleY
//   */
//   void zoomToCenter(double scaleX, double scaleY) {
//
//    MPPointF center = getCenterOffsets();
//
//    Matrix save = mZoomMatrixBuffer;
//    mViewPortHandler.zoom(scaleX, scaleY, center.x, -center.y, save);
//    mViewPortHandler.refresh(save, this, false);
//  }
//
//  /**
//   * Zooms by the specified scale factor to the specified values on the specified axis.
//   *
//   * @param scaleX
//   * @param scaleY
//   * @param xValue
//   * @param yValue
//   * @param axis
//   * @param duration
//   */
//  @TargetApi(11)
//   void zoomAndCenterAnimated(double scaleX, double scaleY, double xValue, double yValue, AxisDependency axis,
//      long duration) {
//
//    MPPointD origin = getValuesByTouchPoint(mViewPortHandler.contentLeft(), mViewPortHandler.contentTop(), axis);
//
//    Runnable job = AnimatedZoomJob.getInstance(mViewPortHandler, this, getTransformer(axis), getAxis(axis), mXAxis
//        .mAxisRange, scaleX, scaleY, mViewPortHandler.getScaleX(), mViewPortHandler.getScaleY(),
//        xValue, yValue, (double) origin.x, (double) origin.y, duration);
//    addViewportJob(job);
//
//    MPPointD.recycleInstance(origin);
//  }

  Matrix4 mFitScreenMatrixBuffer = Matrix4.identity();

  /**
   * Resets all zooming and dragging and makes the chart fit exactly it's
   * bounds.
   */
  void fitScreen() {
//    Matrix4 save = mFitScreenMatrixBuffer;
//    mViewPortHandler.fitScreen2(save);
//    todo mViewPortHandler.refresh(save, this, false);

//    calculateOffsets();
//    postInvalidate();
  }

  /**
   * Sets the size of the area (range on the y-axis) that should be maximum
   * visible at once.
   *
   * @param maxYRange the maximum visible range on the y-axis
   * @param axis      the axis for which this limit should apply
   */
  void setVisibleYRangeMaximum(double maxYRange, AxisDependency axis) {
    double yScale = getAxisRange(axis) / maxYRange;
    mViewPortHandler.setMinimumScaleY(yScale);
  }

  /**
   * Sets the size of the area (range on the y-axis) that should be minimum visible at once, no further zooming in possible.
   *
   * @param minYRange
   * @param axis      the axis for which this limit should apply
   */
  void setVisibleYRangeMinimum(double minYRange, AxisDependency axis) {
    double yScale = getAxisRange(axis) / minYRange;
    mViewPortHandler.setMaximumScaleY(yScale);
  }

  /**
   * Limits the maximum and minimum y range that can be visible by pinching and zooming.
   *
   * @param minYRange
   * @param maxYRange
   * @param axis
   */
  void setVisibleYRange(
      double minYRange, double maxYRange, AxisDependency axis) {
    double minScale = getAxisRange(axis) / minYRange;
    double maxScale = getAxisRange(axis) / maxYRange;
    mViewPortHandler.setMinMaxScaleY(minScale, maxScale);
  }

  // todo animator
//  /**
//   * Moves the left side of the current viewport to the specified x-position.
//   * This also refreshes the chart by calling invalidate().
//   *
//   * @param xValue
//   */
//  void moveViewToX(double xValue) {
//
//    Runnable job = MoveViewJob.getInstance(mViewPortHandler, xValue, 0f,
//        getTransformer(AxisDependency.LEFT), this);
//
//    addViewportJob(job);
//  }
//
//  /**
//   * This will move the left side of the current viewport to the specified
//   * x-value on the x-axis, and center the viewport to the specified y value on the y-axis.
//   * This also refreshes the chart by calling invalidate().
//   *
//   * @param xValue
//   * @param yValue
//   * @param axis   - which axis should be used as a reference for the y-axis
//   */
//  void moveViewTo(double xValue, double yValue, AxisDependency axis) {
//
//    double yInView = getAxisRange(axis) / mViewPortHandler.getScaleY();
//
//    Runnable job = MoveViewJob.getInstance(mViewPortHandler, xValue, yValue + yInView / 2f,
//        getTransformer(axis), this);
//
//    addViewportJob(job);
//  }
//
//  /**
//   * This will move the left side of the current viewport to the specified x-value
//   * and center the viewport to the y value animated.
//   * This also refreshes the chart by calling invalidate().
//   *
//   * @param xValue
//   * @param yValue
//   * @param axis
//   * @param duration the duration of the animation in milliseconds
//   */
//  @TargetApi(11)
//   void moveViewToAnimated(double xValue, double yValue, AxisDependency axis, long duration) {
//
//    MPPointD bounds = getValuesByTouchPoint(mViewPortHandler.contentLeft(), mViewPortHandler.contentTop(), axis);
//
//    double yInView = getAxisRange(axis) / mViewPortHandler.getScaleY();
//
//    Runnable job = AnimatedMoveViewJob.getInstance(mViewPortHandler, xValue, yValue + yInView / 2f,
//        getTransformer(axis), this, (double) bounds.x, (double) bounds.y, duration);
//
//    addViewportJob(job);
//
//    MPPointD.recycleInstance(bounds);
//  }
//
//  /**
//   * Centers the viewport to the specified y value on the y-axis.
//   * This also refreshes the chart by calling invalidate().
//   *
//   * @param yValue
//   * @param axis   - which axis should be used as a reference for the y-axis
//   */
//   void centerViewToY(double yValue, AxisDependency axis) {
//
//    double valsInView = getAxisRange(axis) / mViewPortHandler.getScaleY();
//
//    Runnable job = MoveViewJob.getInstance(mViewPortHandler, 0f, yValue + valsInView / 2f,
//        getTransformer(axis), this);
//
//    addViewportJob(job);
//  }
//
//  /**
//   * This will move the center of the current viewport to the specified
//   * x and y value.
//   * This also refreshes the chart by calling invalidate().
//   *
//   * @param xValue
//   * @param yValue
//   * @param axis   - which axis should be used as a reference for the y axis
//   */
//   void centerViewTo(double xValue, double yValue, AxisDependency axis) {
//
//    double yInView = getAxisRange(axis) / mViewPortHandler.getScaleY();
//    double xInView = getXAxis().mAxisRange / mViewPortHandler.getScaleX();
//
//    Runnable job = MoveViewJob.getInstance(mViewPortHandler,
//        xValue - xInView / 2f, yValue + yInView / 2f,
//        getTransformer(axis), this);
//
//    addViewportJob(job);
//  }
//
//  /**
//   * This will move the center of the current viewport to the specified
//   * x and y value animated.
//   *
//   * @param xValue
//   * @param yValue
//   * @param axis
//   * @param duration the duration of the animation in milliseconds
//   */
//  @TargetApi(11)
//   void centerViewToAnimated(double xValue, double yValue, AxisDependency axis, long duration) {
//
//    MPPointD bounds = getValuesByTouchPoint(mViewPortHandler.contentLeft(), mViewPortHandler.contentTop(), axis);
//
//    double yInView = getAxisRange(axis) / mViewPortHandler.getScaleY();
//    double xInView = getXAxis().mAxisRange / mViewPortHandler.getScaleX();
//
//    Runnable job = AnimatedMoveViewJob.getInstance(mViewPortHandler,
//        xValue - xInView / 2f, yValue + yInView / 2f,
//        getTransformer(axis), this, (double) bounds.x, (double) bounds.y, duration);
//
//    addViewportJob(job);
//
//    MPPointD.recycleInstance(bounds);
//  }

  /**
   * Sets custom offsets for the current ViewPort (the offsets on the sides of
   * the actual chart window). Setting this will prevent the chart from
   * automatically calculating it's offsets. Use resetViewPortOffsets() to
   * undo this. ONLY USE THIS WHEN YOU KNOW WHAT YOU ARE DOING, else use
   * setExtraOffsets(...).
   *
   * @param left
   * @param top
   * @param right
   * @param bottom
   */
  void setViewPortOffsets(final double left, final double top,
      final double right, final double bottom) {
    mCustomViewPortEnabled = true;
    mViewPortHandler.restrainViewPort(left, top, right, bottom);
    prepareOffsetMatrix();
    prepareValuePxMatrix();
  }

  /**
   * Resets all custom offsets set via setViewPortOffsets(...) method. Allows
   * the chart to again calculate all offsets automatically.
   */
  void resetViewPortOffsets() {
//    mCustomViewPortEnabled = false;
//    calculateOffsets();
  }

  /**
   * ################ ################ ################ ################
   */
  /** CODE BELOW IS GETTERS AND SETTERS */

  /**
   * Returns the range of the specified axis.
   *
   * @param axis
   * @return
   */
  double getAxisRange(AxisDependency axis) {
    if (axis == AxisDependency.LEFT)
      return mAxisLeft.mAxisRange;
    else
      return mAxisRight.mAxisRange;
  }

  List<double> mGetPositionBuffer = List(2);

  /**
   * Returns a recyclable MPPointF instance.
   * Returns the position (in pixels) the provided Entry has inside the chart
   * view or null, if the provided Entry is null.
   *
   * @param e
   * @return
   */
  MPPointF getPosition(Entry e, AxisDependency axis) {
    if (e == null) return null;

    mGetPositionBuffer[0] = e.x;
    mGetPositionBuffer[1] = e.y;

    getTransformer(axis).pointValuesToPixel(mGetPositionBuffer);

    return MPPointF.getInstance1(mGetPositionBuffer[0], mGetPositionBuffer[1]);
  }

  /**
   * Sets the color for the background of the chart-drawing area (everything
   * behind the grid lines).
   *
   * @param color
   */
  void setGridBackgroundColor(Color color) {
    mGridBackgroundPaint..color = color;
  }

  /**
   * Sets the width of the border lines in dp.
   *
   * @param width
   */
  void setBorderWidth(double width) {
    mBorderPaint..strokeWidth = Utils.convertDpToPixel(width);
  }

  /**
   * Sets the color of the chart border lines.
   *
   * @param color
   */
  void setBorderColor(Color color) {
    mBorderPaint..color = color;
  }

  /**
   * Returns a recyclable MPPointD instance
   * Returns the x and y values in the chart at the given touch point
   * (encapsulated in a MPPointD). This method transforms pixel coordinates to
   * coordinates / values in the chart. This is the opposite method to
   * getPixelForValues(...).
   *
   * @param x
   * @param y
   * @return
   */
  MPPointD getValuesByTouchPoint1(double x, double y, AxisDependency axis) {
    MPPointD result = MPPointD.getInstance1(0, 0);
    getValuesByTouchPoint2(x, y, axis, result);
    return result;
  }

  void getValuesByTouchPoint2(
      double x, double y, AxisDependency axis, MPPointD outputPoint) {
    getTransformer(axis).getValuesByTouchPoint2(x, y, outputPoint);
  }

  /**
   * Returns a recyclable MPPointD instance
   * Transforms the given chart values into pixels. This is the opposite
   * method to getValuesByTouchPoint(...).
   *
   * @param x
   * @param y
   * @return
   */
  MPPointD getPixelForValues(double x, double y, AxisDependency axis) {
    return getTransformer(axis).getPixelForValues(x, y);
  }

  /**
   * returns the Entry object displayed at the touched position of the chart
   *
   * @param x
   * @param y
   * @return
   */
  Entry getEntryByTouchPoint(double x, double y) {
    Highlight h = getHighlightByTouchPoint(x, y);
    if (h != null) {
      return mData.getEntryForHighlight(h);
    }
    return null;
  }

  /**
   * returns the DataSet object displayed at the touched position of the chart
   *
   * @param x
   * @param y
   * @return
   */
  IBarLineScatterCandleBubbleDataSet getDataSetByTouchPoint(
      double x, double y) {
    Highlight h = getHighlightByTouchPoint(x, y);
    if (h != null) {
      return mData.getDataSetByIndex(h.getDataSetIndex());
    }
    return null;
  }

  /**
   * buffer for storing lowest visible x point
   */
  MPPointD posForGetLowestVisibleX = MPPointD.getInstance1(0, 0);

  /**
   * Returns the lowest x-index (value on the x-axis) that is still visible on
   * the chart.
   *
   * @return
   */
  @override
  double getLowestVisibleX() {
    getTransformer(AxisDependency.LEFT).getValuesByTouchPoint2(
        mViewPortHandler.contentLeft(),
        mViewPortHandler.contentBottom(),
        posForGetLowestVisibleX);
    double result = max(mXAxis.mAxisMinimum, posForGetLowestVisibleX.x);
    return result;
  }

  /**
   * buffer for storing highest visible x point
   */
  MPPointD posForGetHighestVisibleX = MPPointD.getInstance1(0, 0);

  /**
   * Returns the highest x-index (value on the x-axis) that is still visible
   * on the chart.
   *
   * @return
   */
  @override
  double getHighestVisibleX() {
    getTransformer(AxisDependency.LEFT).getValuesByTouchPoint2(
        mViewPortHandler.contentRight(),
        mViewPortHandler.contentBottom(),
        posForGetHighestVisibleX);
    double result = min(mXAxis.mAxisMaximum, posForGetHighestVisibleX.x);
    return result;
  }

  /**
   * Returns the range visible on the x-axis.
   *
   * @return
   */
  double getVisibleXRange() {
    return (getHighestVisibleX() - getLowestVisibleX()).abs();
  }

  /**
   * returns the current x-scale factor
   */
  double getScaleX() {
    if (mViewPortHandler == null)
      return 1;
    else
      return mViewPortHandler.getScaleX();
  }

  /**
   * returns the current y-scale factor
   */
  double getScaleY() {
    if (mViewPortHandler == null)
      return 1;
    else
      return mViewPortHandler.getScaleY();
  }

  /**
   * if the chart is fully zoomed out, return true
   *
   * @return
   */
  bool isFullyZoomedOut() {
    return mViewPortHandler.isFullyZoomedOut();
  }

  /**
   * Returns the y-axis object to the corresponding AxisDependency. In the
   * horizontal bar-chart, LEFT == top, RIGHT == BOTTOM
   *
   * @param axis
   * @return
   */
  YAxis getAxis(AxisDependency axis) {
    if (axis == AxisDependency.LEFT)
      return mAxisLeft;
    else
      return mAxisRight;
  }

  @override
  bool isInverted(AxisDependency axis) {
    return getAxis(axis).isInverted();
  }

  /**
   * Set an offset in dp that allows the user to drag the chart over it's
   * bounds on the x-axis.
   *
   * @param offset
   */
  void setDragOffsetX(double offset) {
    mViewPortHandler.setDragOffsetX(offset);
  }

  /**
   * Set an offset in dp that allows the user to drag the chart over it's
   * bounds on the y-axis.
   *
   * @param offset
   */
  void setDragOffsetY(double offset) {
    mViewPortHandler.setDragOffsetY(offset);
  }

  /**
   * Returns true if both drag offsets (x and y) are zero or smaller.
   *
   * @return
   */
  bool hasNoDragOffset() {
    return mViewPortHandler.hasNoDragOffset();
  }

  @override
  double getYChartMax() {
    return max(mAxisLeft.mAxisMaximum, mAxisRight.mAxisMaximum);
  }

  @override
  double getYChartMin() {
    return min(mAxisLeft.mAxisMinimum, mAxisRight.mAxisMinimum);
  }

  /**
   * Returns true if either the left or the right or both axes are inverted.
   *
   * @return
   */
  bool isAnyAxisInverted() {
    if (mAxisLeft.isInverted()) return true;
    if (mAxisRight.isInverted()) return true;
    return false;
  }

//  @override
//  TextPainter setPaint(TextPainter p, int which) {
//    super.setPaint(p, which);
//
//    switch (which) {
//      case PAINT_GRID_BACKGROUND:
//        mGridBackgroundPaint = p;
//        break;
//    }
//  }
//
//  @override
//  TextPainter getPaint(int which) {
//    TextPainter p = super.getPaint(which);
//    if (p != null)
//      return p;
//
//    switch (which) {
//      case PAINT_GRID_BACKGROUND:
//        return mGridBackgroundPaint;
//    }
//
//    return null;
//  }

  List<double> mOnSizeChangedBuffer = List(2);

//  @Override
//  protected void onSizeChanged(int w, int h, int oldw, int oldh) {
//
//    // Saving current position of chart.
//    mOnSizeChangedBuffer[0] = mOnSizeChangedBuffer[1] = 0;
//
//    if (mKeepPositionOnRotation) {
//      mOnSizeChangedBuffer[0] = mViewPortHandler.contentLeft();
//      mOnSizeChangedBuffer[1] = mViewPortHandler.contentTop();
//      getTransformer(AxisDependency.LEFT).pixelsToValue(mOnSizeChangedBuffer);
//    }
//
//    //Superclass transforms chart.
//    super.onSizeChanged(w, h, oldw, oldh);
//
//    if (mKeepPositionOnRotation) {
//
//      //Restoring old position of chart.
//      getTransformer(AxisDependency.LEFT).pointValuesToPixel(mOnSizeChangedBuffer);
//      mViewPortHandler.centerViewPort(mOnSizeChangedBuffer, this);
//    } else {
//      mViewPortHandler.refresh(mViewPortHandler.getMatrixTouch(), this, true);
//    }
//  }
}
