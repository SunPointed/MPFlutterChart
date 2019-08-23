import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/rendering/custom_paint.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/render.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_line_chart_painter.dart';

enum DrawOrder { BAR, BUBBLE, LINE, CANDLE, SCATTER }

class CombinedChartPainter extends BarLineChartBasePainter<CombinedData>
    implements CombinedDataProvider {
  /**
   * if set to true, all values are drawn above their bars, instead of below
   * their top
   */
  bool mDrawValueAboveBar = true;

  /**
   * flag that indicates whether the highlight should be full-bar oriented, or single-value?
   */
  bool mHighlightFullBarEnabled = false;

  /**
   * if set to true, a grey area is drawn behind each bar that indicates the
   * maximum value
   */
  bool mDrawBarShadow = false;

  List<DrawOrder> mDrawOrder;

  CombinedChartPainter(CombinedData data,
      {bool drawValueAboveBar = true,
      bool highlightFullBarEnabled = false,
      bool drawBarShadow = false,
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
      : mDrawBarShadow = drawBarShadow,
        mHighlightFullBarEnabled = highlightFullBarEnabled,
        mDrawValueAboveBar = drawValueAboveBar,
        super(data,
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
    super.init();

    // Default values are not ready here yet
    mDrawOrder = List()
      ..add(DrawOrder.BAR)
      ..add(DrawOrder.BUBBLE)
      ..add(DrawOrder.LINE)
      ..add(DrawOrder.CANDLE)
      ..add(DrawOrder.SCATTER);

    mHighlighter = CombinedHighlighter(this, this);

    // Old default behaviour
    mHighlightFullBarEnabled = true;

    mRenderer = CombinedChartRenderer(this, mAnimator, mViewPortHandler);

    (mRenderer as CombinedChartRenderer).createRenderers();
    mRenderer.initBuffers();
  }

  @override
  CombinedData getCombinedData() {
    return mData;
  }

//  @override
//  void setData(CombinedData data) {
//    super.setData(data);
//    setHighlighter(new CombinedHighlighter(this, this));
//    ((CombinedChartRenderer)mRenderer).createRenderers();
//    mRenderer.initBuffers();
//  }

  /**
   * Returns the Highlight object (contains x-index and DataSet index) of the selected value at the given touch
   * point
   * inside the CombinedChart.
   *
   * @param x
   * @param y
   * @return
   */
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

  @override
  LineData getLineData() {
    if (mData == null) return null;
    return mData.getLineData();
  }

  @override
  BarData getBarData() {
    if (mData == null) return null;
    return mData.getBarData();
  }

  @override
  ScatterData getScatterData() {
    if (mData == null) return null;
    return mData.getScatterData();
  }

  @override
  CandleData getCandleData() {
    if (mData == null) return null;
    return mData.getCandleData();
  }

  @override
  BubbleData getBubbleData() {
    if (mData == null) return null;
    return mData.getBubbleData();
  }

  @override
  bool isDrawBarShadowEnabled() {
    return mDrawBarShadow;
  }

  @override
  bool isDrawValueAboveBarEnabled() {
    return mDrawValueAboveBar;
  }

  /**
   * If set to true, all values are drawn above their bars, instead of below
   * their top.
   *
   * @param enabled
   */
  void setDrawValueAboveBar(bool enabled) {
    mDrawValueAboveBar = enabled;
  }

  /**
   * If set to true, a grey area is drawn behind each bar that indicates the
   * maximum value. Enabling his will reduce performance by about 50%.
   *
   * @param enabled
   */
  void setDrawBarShadow(bool enabled) {
    mDrawBarShadow = enabled;
  }

  /**
   * Set this to true to make the highlight operation full-bar oriented,
   * false to make it highlight single values (relevant only for stacked).
   *
   * @param enabled
   */
  void setHighlightFullBarEnabled(bool enabled) {
    mHighlightFullBarEnabled = enabled;
  }

  /**
   * @return true the highlight operation is be full-bar oriented, false if single-value
   */
  @override
  bool isHighlightFullBarEnabled() {
    return mHighlightFullBarEnabled;
  }

  /**
   * Returns the currently set draw order.
   *
   * @return
   */
  List<DrawOrder> getDrawOrder() {
    return mDrawOrder;
  }

  /**
   * Sets the order in which the provided data objects should be drawn. The
   * earlier you place them in the provided array, the further they will be in
   * the background. e.g. if you provide new DrawOrer[] { DrawOrder.BAR,
   * DrawOrder.LINE }, the bars will be drawn behind the lines.
   *
   * @param order
   */
  void setDrawOrder(List<DrawOrder> order) {
    if (order == null || order.length <= 0) return;
    mDrawOrder = order;
  }

  /**
   * draws all MarkerViews on the highlighted positions
   */
  void drawMarkers(Canvas canvas) {
    // if there is no marker view or drawing marker is disabled
    if (mMarker == null || !isDrawMarkersEnabled() || !valuesToHighlight())
      return;

    for (int i = 0; i < mIndicesToHighlight.length; i++) {
      Highlight highlight = mIndicesToHighlight[i];

      IDataSet set = mData.getDataSetByHighlight(highlight);

      Entry e = mData.getEntryForHighlight(highlight);
      if (e == null) continue;

      int entryIndex = set.getEntryIndex2(e);

      // make sure entry not null
      if (entryIndex > set.getEntryCount() * mAnimator.getPhaseX()) continue;

      List<double> pos = getMarkerPosition(highlight);

      // check bounds
      if (!mViewPortHandler.isInBounds(pos[0], pos[1])) continue;

      // callbacks to update the content
      mMarker.refreshContent(e, highlight);

      // draw the marker
      mMarker.draw(canvas, pos[0], pos[1]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
