import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_chart_painter.dart';

class HorizontalBarChartPainter extends BarChartPainter {
  HorizontalBarChartPainter(
      BarData data,
      ChartAnimator animator,
      ViewPortHandler viewPortHandler,
      double maxHighlightDistance,
      bool highLightPerTapEnabled,
      bool dragDecelerationEnabled,
      double dragDecelerationFrictionCoef,
      double extraLeftOffset,
      double extraTopOffset,
      double extraRightOffset,
      double extraBottomOffset,
      String noDataText,
      bool touchEnabled,
      IMarker marker,
      Description desc,
      bool drawMarkers,
      TextPainter infoPainter,
      TextPainter descPainter,
      IHighlighter highlighter,
      XAxis xAxis,
      Legend legend,
      LegendRenderer legendRenderer,
      DataRenderer renderer,
      OnChartValueSelectedListener selectedListener,
      int maxVisibleCount,
      bool autoScaleMinMaxEnabled,
      bool pinchZoomEnabled,
      bool doubleTapToZoomEnabled,
      bool highlightPerDragEnabled,
      bool dragXEnabled,
      bool dragYEnabled,
      bool scaleXEnabled,
      bool scaleYEnabled,
      Paint gridBackgroundPaint,
      Paint borderPaint,
      bool drawGridBackground,
      bool drawBorders,
      bool clipValuesToContent,
      double minOffset,
      bool keepPositionOnRotation,
      OnDrawListener drawListener,
      YAxis axisLeft,
      YAxis axisRight,
      YAxisRenderer axisRendererLeft,
      YAxisRenderer axisRendererRight,
      Transformer leftAxisTransformer,
      Transformer rightAxisTransformer,
      XAxisRenderer xAxisRenderer,
      Matrix4 zoomMatrixBuffer,
      bool customViewPortEnabled,
      double minXRange,
      double maxXRange,
      double minimumScaleX,
      double minimumScaleY,
      Color backgroundColor,
      Color borderColor,
      double borderStrokeWidth,
      bool highlightFullBarEnabled,
      bool drawValueAboveBar,
      bool drawBarShadow,
      bool fitBars)
      : super(
            data,
            animator,
            viewPortHandler,
            maxHighlightDistance,
            highLightPerTapEnabled,
            dragDecelerationEnabled,
            dragDecelerationFrictionCoef,
            extraLeftOffset,
            extraTopOffset,
            extraRightOffset,
            extraBottomOffset,
            noDataText,
            touchEnabled,
            marker,
            desc,
            drawMarkers,
            infoPainter,
            descPainter,
            highlighter,
            xAxis,
            legend,
            legendRenderer,
            renderer,
            selectedListener,
            maxVisibleCount,
            autoScaleMinMaxEnabled,
            pinchZoomEnabled,
            doubleTapToZoomEnabled,
            highlightPerDragEnabled,
            dragXEnabled,
            dragYEnabled,
            scaleXEnabled,
            scaleYEnabled,
            gridBackgroundPaint,
            borderPaint,
            drawGridBackground,
            drawBorders,
            clipValuesToContent,
            minOffset,
            keepPositionOnRotation,
            drawListener,
            axisLeft,
            axisRight,
            axisRendererLeft,
            axisRendererRight,
            leftAxisTransformer,
            rightAxisTransformer,
            xAxisRenderer,
            zoomMatrixBuffer,
            customViewPortEnabled,
            minXRange,
            maxXRange,
            minimumScaleX,
            minimumScaleY,
            backgroundColor,
            borderColor,
            borderStrokeWidth,
            highlightFullBarEnabled,
            drawValueAboveBar,
            drawBarShadow,
            fitBars);

//  @override
//  void init() {
//    if (viewPortHandler == null ||
//        !(viewPortHandler is HorizontalViewPortHandler)) {
//      viewPortHandler = HorizontalViewPortHandler();
//    }
//    super.init();
//    mLeftAxisTransformer = TransformerHorizontalBarChart(viewPortHandler);
//    mRightAxisTransformer = TransformerHorizontalBarChart(viewPortHandler);
//
//    renderer = HorizontalBarChartRenderer(this, mAnimator, viewPortHandler);
//    mHighlighter = HorizontalBarHighlighter(this);
//
//    axisRendererLeft = YAxisRendererHorizontalBarChart(
//        viewPortHandler, axisLeft, mLeftAxisTransformer);
//    mAxisRendererRight = YAxisRendererHorizontalBarChart(
//        viewPortHandler, axisRight, mRightAxisTransformer);
//    xAxisRenderer = XAxisRendererHorizontalBarChart(
//        viewPortHandler, xAxis, mLeftAxisTransformer);
//  }

  Rect _offsetsBuffer = Rect.zero;

  @override
  void calculateOffsets() {
    if (legend != null) legendRenderer.computeLegend(getBarData());
    renderer?.initBuffers();
    calcMinMax();

    double offsetLeft = 0, offsetRight = 0, offsetTop = 0, offsetBottom = 0;

    calculateLegendOffsets(_offsetsBuffer);

    offsetLeft += _offsetsBuffer.left;
    offsetTop += _offsetsBuffer.top;
    offsetRight += _offsetsBuffer.right;
    offsetBottom += _offsetsBuffer.bottom;

    // offsets for y-labels
    if (axisLeft.needsOffset()) {
      offsetTop += axisLeft
          .getRequiredHeightSpace(axisRendererLeft.getPaintAxisLabels());
    }

    if (axisRight.needsOffset()) {
      offsetBottom += axisRight
          .getRequiredHeightSpace(axisRendererRight.getPaintAxisLabels());
    }

    double xlabelwidth = xAxis.mLabelRotatedWidth.toDouble();

    if (xAxis.isEnabled()) {
      // offsets for x-labels
      if (xAxis.getPosition() == XAxisPosition.BOTTOM) {
        offsetLeft += xlabelwidth;
      } else if (xAxis.getPosition() == XAxisPosition.TOP) {
        offsetRight += xlabelwidth;
      } else if (xAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
        offsetLeft += xlabelwidth;
        offsetRight += xlabelwidth;
      }
    }

    offsetTop += extraTopOffset;
    offsetRight += extraRightOffset;
    offsetBottom += extraBottomOffset;
    offsetLeft += extraLeftOffset;

    double offset = Utils.convertDpToPixel(minOffset);

    viewPortHandler.restrainViewPort(
        max(offset, offsetLeft),
        max(offset, offsetTop),
        max(offset, offsetRight),
        max(offset, offsetBottom));

    prepareOffsetMatrix();
    prepareValuePxMatrix();
  }

  @override
  void prepareValuePxMatrix() {
    rightAxisTransformer.prepareMatrixValuePx(axisRight.mAxisMinimum,
        axisRight.mAxisRange, xAxis.mAxisRange, xAxis.mAxisMinimum);
    leftAxisTransformer.prepareMatrixValuePx(axisLeft.mAxisMinimum,
        axisLeft.mAxisRange, xAxis.mAxisRange, xAxis.mAxisMinimum);
  }

  @override
  List<double> getMarkerPosition(Highlight high) {
    return new List()..add(high.getDrawY())..add(high.getDrawX());
  }

  @override
  Rect getBarBounds(BarEntry e) {
    Rect bounds = Rect.zero;
    IBarDataSet set = getBarData().getDataSetForEntry(e);

    if (set == null) {
      bounds = Rect.fromLTRB(double.minPositive, double.minPositive,
          double.minPositive, double.minPositive);
      return bounds;
    }

    double y = e.y;
    double x = e.x;

    double barWidth = getBarData().getBarWidth();

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
    if (getBarData() != null) {
      return highlighter.getHighlight(y, x); // switch x and y
    }
    return null;
  }

  @override
  double getLowestVisibleX() {
    getTransformer(AxisDependency.LEFT).getValuesByTouchPoint2(
        viewPortHandler.contentLeft(),
        viewPortHandler.contentBottom(),
        posForGetLowestVisibleX);
    double result = max(xAxis.mAxisMinimum, posForGetLowestVisibleX.y);
    return result;
  }

  @override
  double getHighestVisibleX() {
    getTransformer(AxisDependency.LEFT).getValuesByTouchPoint2(
        viewPortHandler.contentLeft(),
        viewPortHandler.contentTop(),
        posForGetHighestVisibleX);
    double result = min(xAxis.mAxisMaximum, posForGetHighestVisibleX.y);
    return result;
  }

  /// ###### VIEWPORT METHODS BELOW THIS ######

//  void setVisibleXRangeMaximum(double maxXRange) {
//    double xScale = xAxis.mAxisRange / (maxXRange);
//    viewPortHandler.setMinimumScaleY(xScale);
//  }
//
//  void setVisibleXRangeMinimum(double minXRange) {
//    double xScale = xAxis.mAxisRange / (minXRange);
//    viewPortHandler.setMaximumScaleY(xScale);
//  }
//
//  void setVisibleXRange(double minXRange, double maxXRange) {
//    double minScale = xAxis.mAxisRange / minXRange;
//    double maxScale = xAxis.mAxisRange / maxXRange;
//    viewPortHandler.setMinMaxScaleY(minScale, maxScale);
//  }

  @override
  void setVisibleYRangeMaximum(double maxYRange, AxisDependency axis) {
    double yScale = getAxisRange(axis) / maxYRange;
    viewPortHandler.setMinimumScaleX(yScale);
  }

  @override
  void setVisibleYRangeMinimum(double minYRange, AxisDependency axis) {
    double yScale = getAxisRange(axis) / minYRange;
    viewPortHandler.setMaximumScaleX(yScale);
  }

  @override
  void setVisibleYRange(
      double minYRange, double maxYRange, AxisDependency axis) {
    double minScale = getAxisRange(axis) / minYRange;
    double maxScale = getAxisRange(axis) / maxYRange;
    viewPortHandler.setMinMaxScaleX(minScale, maxScale);
  }
}
