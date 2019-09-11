import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/horizontal_bar_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/horizontal_bar_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer_horizontal_bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer_horizontal_bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer_horizontal_bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class HorizontalBarChartPainter extends BarChartPainter {
  HorizontalBarChartPainter(BarData data,
      {bool highlightFullBarEnabled = false,
      bool drawValueAboveBar = false,
      bool drawBarShadow = false,
      bool fitBars = false,
      ViewPortHandler viewPortHandler = null,
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
      : super(data,
            highlightFullBarEnabled: highlightFullBarEnabled,
            drawValueAboveBar: drawValueAboveBar,
            drawBarShadow: drawBarShadow,
            fitBars: fitBars,
            viewPortHandler: viewPortHandler,
            animator: animator,
            leftAxisTransformer: leftAxisTransformer,
            rightAxisTransformer: rightAxisTransformer,
            zoomMatrixBuffer: zoomMatrixBuffer,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderStrokeWidth: borderStrokeWidth,
            keepPositionOnRotation: keepPositionOnRotation,
            pinchZoomEnabled: pinchZoomEnabled,
            xAxisRenderer: xAxisRenderer,
            rendererLeftYAxis: rendererLeftYAxis,
            rendererRightYAxis: rendererRightYAxis,
            autoScaleMinMaxEnabled: autoScaleMinMaxEnabled,
            minOffset: minOffset,
            clipValuesToContent: clipValuesToContent,
            drawBorders: drawBorders,
            drawGridBackground: drawGridBackground,
            doubleTapToZoomEnabled: doubleTapToZoomEnabled,
            scaleXEnabled: scaleXEnabled,
            scaleYEnabled: scaleYEnabled,
            dragXEnabled: dragXEnabled,
            dragYEnabled: dragYEnabled,
            highlightPerDragEnabled: highlightPerDragEnabled,
            maxVisibleCount: maxVisibleCount,
            drawListener: drawListener,
            minXRange: minXRange,
            maxXRange: maxXRange,
            minimumScaleX: minimumScaleX,
            minimumScaleY: minimumScaleY,
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
    if (mViewPortHandler == null ||
        !(mViewPortHandler is HorizontalViewPortHandler)) {
      mViewPortHandler = HorizontalViewPortHandler();
    }
    super.init();
    mLeftAxisTransformer = TransformerHorizontalBarChart(mViewPortHandler);
    mRightAxisTransformer = TransformerHorizontalBarChart(mViewPortHandler);

    mRenderer = HorizontalBarChartRenderer(this, mAnimator, mViewPortHandler);
    mHighlighter = HorizontalBarHighlighter(this);

    mAxisRendererLeft = YAxisRendererHorizontalBarChart(
        mViewPortHandler, mAxisLeft, mLeftAxisTransformer);
    mAxisRendererRight = YAxisRendererHorizontalBarChart(
        mViewPortHandler, mAxisRight, mRightAxisTransformer);
    mXAxisRenderer = XAxisRendererHorizontalBarChart(
        mViewPortHandler, mXAxis, mLeftAxisTransformer);
  }

  Rect mOffsetsBuffer = Rect.zero;

  @override
  void calculateOffsets() {
    if (mLegend != null) mLegendRenderer.computeLegend(mData);
    mRenderer?.initBuffers();
    calcMinMax();

    double offsetLeft = 0, offsetRight = 0, offsetTop = 0, offsetBottom = 0;

    calculateLegendOffsets(mOffsetsBuffer);

    offsetLeft += mOffsetsBuffer.left;
    offsetTop += mOffsetsBuffer.top;
    offsetRight += mOffsetsBuffer.right;
    offsetBottom += mOffsetsBuffer.bottom;

    // offsets for y-labels
    if (mAxisLeft.needsOffset()) {
      offsetTop += mAxisLeft
          .getRequiredHeightSpace(mAxisRendererLeft.getPaintAxisLabels());
    }

    if (mAxisRight.needsOffset()) {
      offsetBottom += mAxisRight
          .getRequiredHeightSpace(mAxisRendererRight.getPaintAxisLabels());
    }

    double xlabelwidth = mXAxis.mLabelRotatedWidth.toDouble();

    if (mXAxis.isEnabled()) {
      // offsets for x-labels
      if (mXAxis.getPosition() == XAxisPosition.BOTTOM) {
        offsetLeft += xlabelwidth;
      } else if (mXAxis.getPosition() == XAxisPosition.TOP) {
        offsetRight += xlabelwidth;
      } else if (mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
        offsetLeft += xlabelwidth;
        offsetRight += xlabelwidth;
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

    prepareOffsetMatrix();
    prepareValuePxMatrix();
  }

  @override
  void prepareValuePxMatrix() {
    mRightAxisTransformer.prepareMatrixValuePx(mAxisRight.mAxisMinimum,
        mAxisRight.mAxisRange, mXAxis.mAxisRange, mXAxis.mAxisMinimum);
    mLeftAxisTransformer.prepareMatrixValuePx(mAxisLeft.mAxisMinimum,
        mAxisLeft.mAxisRange, mXAxis.mAxisRange, mXAxis.mAxisMinimum);
  }

  @override
  List<double> getMarkerPosition(Highlight high) {
    return new List()..add(high.getDrawY())..add(high.getDrawX());
  }

  @override
  Rect getBarBounds(BarEntry e) {
    Rect bounds = Rect.zero;
    IBarDataSet set = mData.getDataSetForEntry(e);

    if (set == null) {
      bounds = Rect.fromLTRB(double.minPositive, double.minPositive,
          double.minPositive, double.minPositive);
      return bounds;
    }

    double y = e.y;
    double x = e.x;

    double barWidth = mData.getBarWidth();

    double top = x - barWidth / 2;
    double bottom = x + barWidth / 2;
    double left = y >= 0 ? y : 0;
    double right = y <= 0 ? y : 0;

    bounds = Rect.fromLTRB(left, top, right, bottom);

    return getTransformer(set.getAxisDependency()).rectValueToPixel(bounds);
  }

  List<double> mGetPositionBuffer = List(2);

  /// Returns a recyclable MPPointF instance.
  ///
  /// @param e
  /// @param axis
  /// @return
  @override
  MPPointF getPosition(Entry e, AxisDependency axis) {
    if (e == null) return null;

    List<double> vals = mGetPositionBuffer;
    vals[0] = e.y;
    vals[1] = e.x;

    getTransformer(axis).pointValuesToPixel(vals);

    return MPPointF.getInstance1(vals[0], vals[1]);
  }

  /// Returns the Highlight object (contains x-index and DataSet index) of the selected value at the given touch point
  /// inside the BarChart.
  ///
  /// @param x
  /// @param y
  /// @return
  @override
  Highlight getHighlightByTouchPoint(double x, double y) {
    if (mData != null) {
      return mHighlighter.getHighlight(y, x);// switch x and y
    }
    return null;
  }

  @override
  double getLowestVisibleX() {
    getTransformer(AxisDependency.LEFT).getValuesByTouchPoint2(
        mViewPortHandler.contentLeft(),
        mViewPortHandler.contentBottom(),
        posForGetLowestVisibleX);
    double result = max(mXAxis.mAxisMinimum, posForGetLowestVisibleX.y);
    return result;
  }

  @override
  double getHighestVisibleX() {
    getTransformer(AxisDependency.LEFT).getValuesByTouchPoint2(
        mViewPortHandler.contentLeft(),
        mViewPortHandler.contentTop(),
        posForGetHighestVisibleX);
    double result = min(mXAxis.mAxisMaximum, posForGetHighestVisibleX.y);
    return result;
  }

  /// ###### VIEWPORT METHODS BELOW THIS ######

  void setVisibleXRangeMaximum(double maxXRange) {
    double xScale = mXAxis.mAxisRange / (maxXRange);
    mViewPortHandler.setMinimumScaleY(xScale);
  }

  void setVisibleXRangeMinimum(double minXRange) {
    double xScale = mXAxis.mAxisRange / (minXRange);
    mViewPortHandler.setMaximumScaleY(xScale);
  }

  void setVisibleXRange(double minXRange, double maxXRange) {
    double minScale = mXAxis.mAxisRange / minXRange;
    double maxScale = mXAxis.mAxisRange / maxXRange;
    mViewPortHandler.setMinMaxScaleY(minScale, maxScale);
  }

  @override
  void setVisibleYRangeMaximum(double maxYRange, AxisDependency axis) {
    double yScale = getAxisRange(axis) / maxYRange;
    mViewPortHandler.setMinimumScaleX(yScale);
  }

  @override
  void setVisibleYRangeMinimum(double minYRange, AxisDependency axis) {
    double yScale = getAxisRange(axis) / minYRange;
    mViewPortHandler.setMaximumScaleX(yScale);
  }

  @override
  void setVisibleYRange(
      double minYRange, double maxYRange, AxisDependency axis) {
    double minScale = getAxisRange(axis) / minYRange;
    double maxScale = getAxisRange(axis) / maxYRange;
    mViewPortHandler.setMinMaxScaleX(minScale, maxScale);
  }
}
