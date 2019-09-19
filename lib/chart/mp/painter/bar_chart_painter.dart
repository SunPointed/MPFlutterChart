import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/rendering/custom_paint.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bar_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/fill_formatter/bar_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/bar_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_line_chart_painter.dart';

class BarChartPainter extends BarLineChartBasePainter<BarData>
    implements BarDataProvider {
  /// flag that indicates whether the highlight should be full-bar oriented, or single-value?
  bool mHighlightFullBarEnabled = false;

  /// if set to true, all values are drawn above their bars, instead of below their top
  bool mDrawValueAboveBar = true;

  /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
  bool mDrawBarShadow = false;

  bool mFitBars = false;

  BarChartPainter(BarData data, ChartAnimator animator,
      {bool highlightFullBarEnabled = false,
      bool drawValueAboveBar = false,
      bool drawBarShadow = false,
      bool fitBars = false,
      ViewPortHandler viewPortHandler = null,
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
      : mHighlightFullBarEnabled = highlightFullBarEnabled,
        mDrawValueAboveBar = drawValueAboveBar,
        mDrawBarShadow = drawBarShadow,
        mFitBars = fitBars,
        super(data, animator,
            viewPortHandler: viewPortHandler,
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
    super.init();
    mRenderer = BarChartRenderer(this, mAnimator, mViewPortHandler);

    mHighlighter = BarHighlighter(this);

    mXAxis.setSpaceMin(0.5);
    mXAxis.setSpaceMax(0.5);
  }

  @override
  void calcMinMax() {
    if (mFitBars) {
      mXAxis.calculate(mData.getXMin() - mData.getBarWidth() / 2.0,
          mData.getXMax() + mData.getBarWidth() / 2.0);
    } else {
      mXAxis.calculate(mData.getXMin(), mData.getXMax());
    }

    // calculate axis range (min / max) according to provided data
    mAxisLeft.calculate(mData.getYMin2(AxisDependency.LEFT),
        mData.getYMax2(AxisDependency.LEFT));
    mAxisRight.calculate(mData.getYMin2(AxisDependency.RIGHT),
        mData.getYMax2(AxisDependency.RIGHT));
  }

  /// Returns the Highlight object (contains x-index and DataSet index) of the selected value at the given touch
  /// point
  /// inside the BarChart.
  ///
  /// @param x
  /// @param y
  /// @return
  @override
  Highlight getHighlightByTouchPoint(double x, double y) {
    if (mData == null) {
      return null;
    } else {
      Highlight h = mHighlighter.getHighlight(x, y);
      if (h == null || !isHighlightFullBarEnabled()) return h;

      // For isHighlightFullBarEnabled, remove stackIndex
      return Highlight(
          x: h.mX,
          y: h.mY,
          xPx: h.mXPx,
          yPx: h.mYPx,
          dataSetIndex: h.getDataSetIndex(),
          stackIndex: -1,
          axis: h.getAxis());
    }
  }

  /// The passed outputRect will be assigned the values of the bounding box of the specified Entry in the specified DataSet.
  /// The rect will be assigned Float.MIN_VALUE in all locations if the Entry could not be found in the charts data.
  ///
  /// @param e
  /// @return
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

    double left = x - barWidth / 2.0;
    double right = x + barWidth / 2.0;
    double top = y >= 0 ? y : 0;
    double bottom = y <= 0 ? y : 0;

    bounds = Rect.fromLTRB(left, top, right, bottom);

    return getTransformer(set.getAxisDependency()).rectValueToPixel(bounds);
  }

  /// If set to true, all values are drawn above their bars, instead of below their top.
  ///
  /// @param enabled
  void setDrawValueAboveBar(bool enabled) {
    mDrawValueAboveBar = enabled;
  }

  /// returns true if drawing values above bars is enabled, false if not
  ///
  /// @return
  bool isDrawValueAboveBarEnabled() {
    return mDrawValueAboveBar;
  }

  /// If set to true, a grey area is drawn behind each bar that indicates the maximum value. Enabling his will reduce
  /// performance by about 50%.
  ///
  /// @param enabled
  void setDrawBarShadow(bool enabled) {
    mDrawBarShadow = enabled;
  }

  /// returns true if drawing shadows (maxvalue) for each bar is enabled, false if not
  ///
  /// @return
  bool isDrawBarShadowEnabled() {
    return mDrawBarShadow;
  }

  /// Set this to true to make the highlight operation full-bar oriented, false to make it highlight single values (relevant
  /// only for stacked). If enabled, highlighting operations will highlight the whole bar, even if only a single stack entry
  /// was tapped.
  /// Default: false
  ///
  /// @param enabled
  void setHighlightFullBarEnabled(bool enabled) {
    mHighlightFullBarEnabled = enabled;
  }

  /// @return true the highlight operation is be full-bar oriented, false if single-value
  @override
  bool isHighlightFullBarEnabled() {
    return mHighlightFullBarEnabled;
  }

  /// Highlights the value at the given x-value in the given DataSet. Provide
  /// -1 as the dataSetIndex to undo all highlighting.
  ///
  /// @param x
  /// @param dataSetIndex
  /// @param stackIndex   the index inside the stack - only relevant for stacked entries
  void highlightValue(double x, int dataSetIndex, int stackIndex) {
    highlightValue6(
        Highlight(x: x, dataSetIndex: dataSetIndex, stackIndex: stackIndex),
        false);
  }

  @override
  BarData getBarData() {
    return mData;
  }

  /// Adds half of the bar width to each side of the x-axis range in order to allow the bars of the barchart to be
  /// fully displayed.
  /// Default: false
  ///
  /// @param enabled
  void setFitBars(bool enabled) {
    mFitBars = enabled;
  }

  /// Groups all BarDataSet objects this data object holds together by modifying the x-value of their entries.
  /// Previously set x-values of entries will be overwritten. Leaves space between bars and groups as specified
  /// by the parameters.
  /// Calls notifyDataSetChanged() afterwards.
  ///
  /// @param fromX      the starting point on the x-axis where the grouping should begin
  /// @param groupSpace the space between groups of bars in values (not pixels) e.g. 0.8f for bar width 1f
  /// @param barSpace   the space between individual bars in values (not pixels) e.g. 0.1f for bar width 1f
  void groupBars(double fromX, double groupSpace, double barSpace) {
    if (getBarData() == null) {
      throw Exception(
          "You need to set data for the chart before grouping bars.");
    } else {
      getBarData().groupBars(fromX, groupSpace, barSpace);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
