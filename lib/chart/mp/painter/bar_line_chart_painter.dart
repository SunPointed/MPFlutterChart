import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_line_scatter_candle_bubble_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bar_line_scatter_candle_bubble_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
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
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/matrix4_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

abstract class BarLineChartBasePainter<
        T extends BarLineScatterCandleBubbleData<
            IBarLineScatterCandleBubbleDataSet<Entry>>> extends ChartPainter<T>
    implements BarLineScatterCandleBubbleDataProvider {
  /// the maximum number of entries to which values will be drawn
  /// (entry numbers greater than this value will cause value-labels to disappear)
  final int _maxVisibleCount;

  /// flag that indicates if auto scaling on the y axis is enabled
  final bool _autoScaleMinMaxEnabled;

  /// flag that indicates if pinch-zoom is enabled. if true, both x and y axis
  /// can be scaled with 2 fingers, if false, x and y axis can be scaled
  /// separately
  final bool _pinchZoomEnabled;

  /// flag that indicates if double tap zoom is enabled or not
  final bool _doubleTapToZoomEnabled;

  /// flag that indicates if highlighting per dragging over a fully zoomed out
  /// chart is enabled
  final bool _highlightPerDragEnabled;

  /// if true, dragging is enabled for the chart
  final bool _dragXEnabled;
  final bool _dragYEnabled;

  final bool _scaleXEnabled;
  final bool _scaleYEnabled;

  /// paint object for the (by default) lightgrey background of the grid
  final Paint _gridBackgroundPaint;

  final Paint _borderPaint;

  /// flag indicating if the grid background should be drawn or not
  final bool _drawGridBackground;

  final bool _drawBorders;

  final bool _clipValuesToContent;

  /// Sets the minimum offset (padding) around the chart, defaults to 15
  final double _minOffset;

  /// flag indicating if the chart should stay at the same position after a rotation. Default is false.
  final bool _keepPositionOnRotation;

  /// the listener for user drawing on the chart
  final OnDrawListener _drawListener;

  /// the object representing the labels on the left y-axis
  final YAxis _axisLeft;

  /// the object representing the labels on the right y-axis
  final YAxis _axisRight;

  final YAxisRenderer _axisRendererLeft;
  final YAxisRenderer _axisRendererRight;

  final Transformer _leftAxisTransformer;
  final Transformer _rightAxisTransformer;

  final XAxisRenderer _xAxisRenderer;

  /// flag that indicates if a custom viewport offset has been set
  final bool _customViewPortEnabled;

  /// CODE BELOW THIS RELATED TO SCALING AND GESTURES AND MODIFICATION OF THE
  /// VIEWPORT
  final Matrix4 _zoomMatrixBuffer;

  double _minXRange;
  double _maxXRange;
  double _minimumScaleX;
  double _minimumScaleY;
  Color _backgroundColor;
  Color _borderColor;
  double _borderStrokeWidth;

  /////////////////////////////////

  Rect _offsetsBuffer = Rect.zero;

  YAxis get axisLeft => _axisLeft;

  YAxis get axisRight => _axisRight;

  YAxisRenderer get axisRendererLeft => _axisRendererLeft;

  YAxisRenderer get axisRendererRight => _axisRendererRight;

  double get minOffset => _minOffset;

  Transformer get leftAxisTransformer => _leftAxisTransformer;

  Transformer get rightAxisTransformer => _rightAxisTransformer;

  BarLineChartBasePainter(
    T data,
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
  )   : _keepPositionOnRotation = keepPositionOnRotation,
        _leftAxisTransformer = leftAxisTransformer,
        _rightAxisTransformer = rightAxisTransformer,
        _zoomMatrixBuffer = zoomMatrixBuffer,
        _pinchZoomEnabled = pinchZoomEnabled,
        _xAxisRenderer = xAxisRenderer,
        _axisRendererLeft = axisRendererLeft,
        _axisRendererRight = axisRendererRight,
        _autoScaleMinMaxEnabled = autoScaleMinMaxEnabled,
        _minOffset = minOffset,
        _clipValuesToContent = clipValuesToContent,
        _drawBorders = drawBorders,
        _drawGridBackground = drawGridBackground,
        _doubleTapToZoomEnabled = doubleTapToZoomEnabled,
        _scaleXEnabled = scaleXEnabled,
        _scaleYEnabled = scaleYEnabled,
        _dragXEnabled = dragXEnabled,
        _dragYEnabled = dragYEnabled,
        _highlightPerDragEnabled = highlightPerDragEnabled,
        _maxVisibleCount = maxVisibleCount,
        _customViewPortEnabled = customViewPortEnabled,
        _axisLeft = axisLeft,
        _axisRight = axisRight,
        _drawListener = drawListener,
        _gridBackgroundPaint = gridBackgroundPaint,
        _borderPaint = borderPaint,
        _minXRange = minXRange,
        _maxXRange = maxXRange,
        _minimumScaleX = minimumScaleX,
        _minimumScaleY = minimumScaleY,
        _backgroundColor = backgroundColor,
        _borderColor = borderColor,
        _borderStrokeWidth = borderStrokeWidth,
        super(
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
            selectedListener) {}

//  @override
//  void initDefaultNormal() {
//    super.initDefaultNormal();
//    _gridBackgroundPaint = Paint()
//      ..color = _backgroundColor == null
//          ? Color.fromARGB(255, 240, 240, 240)
//          : _backgroundColor
//      ..style = PaintingStyle.fill;
//
//    _borderPaint = Paint()
//      ..color = _borderColor == null ? ColorUtils.BLACK : _borderColor
//      ..style = PaintingStyle.stroke
//      ..strokeWidth = Utils.convertDpToPixel(_borderStrokeWidth);
//  }

  @override
  void initDefaultWithData() {
    super.initDefaultWithData();
    double minXScale = xAxis.mAxisRange / (_minXRange);
    viewPortHandler.setMaximumScaleX(minXScale);
    double maxXScale = xAxis.mAxisRange / (_maxXRange);
    viewPortHandler.setMinimumScaleX(maxXScale);
    viewPortHandler.setMinimumScaleX(_minimumScaleX);
    viewPortHandler.setMinimumScaleY(_minimumScaleY);
  }

//  @override
//  void init() {
//    _axisLeft = YAxis(position: AxisDependency.LEFT);
//    _axisRight = YAxis(position: AxisDependency.RIGHT);
//
//    _leftAxisTransformer ??= Transformer(viewPortHandler);
//    _rightAxisTransformer ??= Transformer(viewPortHandler);
//    _zoomMatrixBuffer ??= Matrix4.identity();
//
//    _axisRendererLeft ??=
//        YAxisRenderer(viewPortHandler, _axisLeft, _leftAxisTransformer);
//    _axisRendererRight ??=
//        YAxisRenderer(viewPortHandler, _axisRight, _rightAxisTransformer);
//    _xAxisRenderer ??=
//        XAxisRenderer(viewPortHandler, xAxis, _leftAxisTransformer);
//
//    mHighlighter = ChartHighlighter(this);
//  }

  @override
  void onPaint(Canvas canvas, Size size) {
    // execute all drawing commands
    drawGridBackground(canvas);

    if (_autoScaleMinMaxEnabled) {
      autoScale();
    }

    if (_axisLeft.isEnabled())
      _axisRendererLeft.computeAxis(_axisLeft.mAxisMinimum,
          _axisLeft.mAxisMaximum, _axisLeft.isInverted());

    if (_axisRight.isEnabled())
      _axisRendererRight.computeAxis(_axisRight.mAxisMinimum,
          _axisRight.mAxisMaximum, _axisRight.isInverted());
    if (xAxis.isEnabled())
      _xAxisRenderer.computeAxis(xAxis.mAxisMinimum, xAxis.mAxisMaximum, false);

    _xAxisRenderer.renderAxisLine(canvas);
    _axisRendererLeft.renderAxisLine(canvas);
    _axisRendererRight.renderAxisLine(canvas);

    if (xAxis.isDrawGridLinesBehindDataEnabled())
      _xAxisRenderer.renderGridLines(canvas);

    if (_axisLeft.isDrawGridLinesBehindDataEnabled())
      _axisRendererLeft.renderGridLines(canvas);

    if (_axisRight.isDrawGridLinesBehindDataEnabled())
      _axisRendererRight.renderGridLines(canvas);

    if (xAxis.isEnabled() && xAxis.isDrawLimitLinesBehindDataEnabled())
      _xAxisRenderer.renderLimitLines(canvas);

    if (_axisLeft.isEnabled() && _axisLeft.isDrawLimitLinesBehindDataEnabled())
      _axisRendererLeft.renderLimitLines(canvas);

    if (_axisRight.isEnabled() &&
        _axisRight.isDrawLimitLinesBehindDataEnabled())
      _axisRendererRight.renderLimitLines(canvas);

    // make sure the data cannot be drawn outside the content-rect
    canvas.save();
    canvas.clipRect(viewPortHandler.getContentRect());

    renderer.drawData(canvas);

    if (!xAxis.isDrawGridLinesBehindDataEnabled())
      _xAxisRenderer.renderGridLines(canvas);

    if (!_axisLeft.isDrawGridLinesBehindDataEnabled())
      _axisRendererLeft.renderGridLines(canvas);

    if (!_axisRight.isDrawGridLinesBehindDataEnabled())
      _axisRendererRight.renderGridLines(canvas);

    // if highlighting is enabled
    if (valuesToHighlight())
      renderer.drawHighlighted(canvas, indicesToHighlight);

    // Removes clipping rectangle
    canvas.restore();

    renderer.drawExtras(canvas);

    if (xAxis.isEnabled() && !xAxis.isDrawLimitLinesBehindDataEnabled())
      _xAxisRenderer.renderLimitLines(canvas);

    if (_axisLeft.isEnabled() && !_axisLeft.isDrawLimitLinesBehindDataEnabled())
      _axisRendererLeft.renderLimitLines(canvas);

    if (_axisRight.isEnabled() &&
        !_axisRight.isDrawLimitLinesBehindDataEnabled())
      _axisRendererRight.renderLimitLines(canvas);

    _xAxisRenderer.renderAxisLabels(canvas);
    _axisRendererLeft.renderAxisLabels(canvas);
    _axisRendererRight.renderAxisLabels(canvas);

    if (_clipValuesToContent) {
      canvas.save();
      canvas.clipRect(viewPortHandler.getContentRect());

      renderer.drawValues(canvas);

      canvas.restore();
    } else {
      renderer.drawValues(canvas);
    }

    legendRenderer.renderLegend(canvas);

    drawDescription(canvas, size);

    drawMarkers(canvas);
  }

  void prepareValuePxMatrix() {
    _rightAxisTransformer.prepareMatrixValuePx(xAxis.mAxisMinimum,
        xAxis.mAxisRange, _axisRight.mAxisRange, _axisRight.mAxisMinimum);

    _leftAxisTransformer.prepareMatrixValuePx(xAxis.mAxisMinimum,
        xAxis.mAxisRange, _axisLeft.mAxisRange, _axisLeft.mAxisMinimum);
  }

  void prepareOffsetMatrix() {
    _rightAxisTransformer.prepareMatrixOffset(_axisRight.isInverted());
    _leftAxisTransformer.prepareMatrixOffset(_axisLeft.isInverted());
  }

  /// Performs auto scaling of the axis by recalculating the minimum and maximum y-values based on the entries currently in view.
  void autoScale() {
    // todo
  }

  @override
  void calcMinMax() {
    xAxis.calculate(getData().getXMin(), getData().getXMax());
    // calculate axis range (min / max) according to provided data
    _axisLeft.calculate(getData().getYMin2(AxisDependency.LEFT),
        getData().getYMax2(AxisDependency.LEFT));
    _axisRight.calculate(getData().getYMin2(AxisDependency.RIGHT),
        getData().getYMax2(AxisDependency.RIGHT));
  }

  Rect calculateLegendOffsets(Rect offsets) {
    offsets = Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    // setup offsets for legend
    if (legend != null && legend.isEnabled() && !legend.isDrawInsideEnabled()) {
      switch (legend.getOrientation()) {
        case LegendOrientation.VERTICAL:
          switch (legend.getHorizontalAlignment()) {
            case LegendHorizontalAlignment.LEFT:
              offsets = Rect.fromLTRB(
                  min(
                          legend.mNeededWidth,
                          viewPortHandler.getChartWidth() *
                              legend.getMaxSizePercent()) +
                      legend.getXOffset(),
                  0.0,
                  0.0,
                  0.0);
              break;

            case LegendHorizontalAlignment.RIGHT:
              offsets = Rect.fromLTRB(
                  0.0,
                  0.0,
                  min(
                          legend.mNeededWidth,
                          viewPortHandler.getChartWidth() *
                              legend.getMaxSizePercent()) +
                      legend.getXOffset(),
                  0.0);
              break;

            case LegendHorizontalAlignment.CENTER:
              switch (legend.getVerticalAlignment()) {
                case LegendVerticalAlignment.TOP:
                  offsets = Rect.fromLTRB(
                      0.0,
                      min(
                              legend.mNeededHeight,
                              viewPortHandler.getChartHeight() *
                                  legend.getMaxSizePercent()) +
                          legend.getYOffset(),
                      0.0,
                      0.0);
                  break;

                case LegendVerticalAlignment.BOTTOM:
                  offsets = Rect.fromLTRB(
                      0.0,
                      0.0,
                      0.0,
                      min(
                              legend.mNeededHeight,
                              viewPortHandler.getChartHeight() *
                                  legend.getMaxSizePercent()) +
                          legend.getYOffset());
                  break;

                default:
                  break;
              }
          }

          break;

        case LegendOrientation.HORIZONTAL:
          switch (legend.getVerticalAlignment()) {
            case LegendVerticalAlignment.TOP:
              offsets = Rect.fromLTRB(
                  0.0,
                  min(
                          legend.mNeededHeight,
                          viewPortHandler.getChartHeight() *
                              legend.getMaxSizePercent()) +
                      legend.getYOffset(),
                  0.0,
                  0.0);
              break;

            case LegendVerticalAlignment.BOTTOM:
              offsets = Rect.fromLTRB(
                  0.0,
                  0.0,
                  0.0,
                  min(
                          legend.mNeededHeight,
                          viewPortHandler.getChartHeight() *
                              legend.getMaxSizePercent()) +
                      legend.getYOffset());
              break;

            default:
              break;
          }
          break;
      }
    }
    return offsets;
  }

  @override
  void calculateOffsets() {
    if (legend != null) legendRenderer.computeLegend(getData());
    renderer?.initBuffers();
    calcMinMax();
    if (!_customViewPortEnabled) {
      double offsetLeft = 0, offsetRight = 0, offsetTop = 0, offsetBottom = 0;

      _offsetsBuffer = calculateLegendOffsets(_offsetsBuffer);

      offsetLeft += _offsetsBuffer.left;
      offsetTop += _offsetsBuffer.top;
      offsetRight += _offsetsBuffer.right;
      offsetBottom += _offsetsBuffer.bottom;

      // offsets for y-labels
      if (_axisLeft.needsOffset()) {
        offsetLeft += _axisLeft
            .getRequiredWidthSpace(_axisRendererLeft.getPaintAxisLabels());
      }

      if (_axisRight.needsOffset()) {
        offsetRight += _axisRight
            .getRequiredWidthSpace(_axisRendererRight.getPaintAxisLabels());
      }

      if (xAxis.isEnabled() && xAxis.isDrawLabelsEnabled()) {
        double xLabelHeight = xAxis.mLabelRotatedHeight + xAxis.getYOffset();

        // offsets for x-labels
        if (xAxis.getPosition() == XAxisPosition.BOTTOM) {
          offsetBottom += xLabelHeight;
        } else if (xAxis.getPosition() == XAxisPosition.TOP) {
          offsetTop += xLabelHeight;
        } else if (xAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
          offsetBottom += xLabelHeight;
          offsetTop += xLabelHeight;
        }
      }

      offsetTop += extraTopOffset;
      offsetRight += extraRightOffset;
      offsetBottom += extraBottomOffset;
      offsetLeft += extraLeftOffset;

      double minOffset = Utils.convertDpToPixel(_minOffset);

      viewPortHandler.restrainViewPort(
          max(minOffset, offsetLeft),
          max(minOffset, offsetTop),
          max(minOffset, offsetRight),
          max(minOffset, offsetBottom));
    }

    prepareOffsetMatrix();
    prepareValuePxMatrix();
  }

  /// draws the grid background
  void drawGridBackground(Canvas c) {
    if (_drawGridBackground) {
      // draw the grid background
      c.drawRect(viewPortHandler.getContentRect(), _gridBackgroundPaint);
    }

    if (_drawBorders) {
      c.drawRect(viewPortHandler.getContentRect(), _borderPaint);
    }
  }

  /// Returns the Transformer class that contains all matrices and is
  /// responsible for transforming values into pixels on the screen and
  /// backwards.
  ///
  /// @return
  Transformer getTransformer(AxisDependency which) {
    if (which == AxisDependency.LEFT)
      return _leftAxisTransformer;
    else
      return _rightAxisTransformer;
  }

  /// Zooms in or out by the given scale factor. x and y are the coordinates
  /// (in pixels) of the zoom center.
  ///
  /// @param scaleX if < 1f --> zoom out, if > 1f --> zoom in
  /// @param scaleY if < 1f --> zoom out, if > 1f --> zoom in
  /// @param x
  /// @param y
  void zoom(double scaleX, double scaleY, double x, double y) {
    viewPortHandler.zoom4(scaleX, scaleY, x, -y, _zoomMatrixBuffer);
    viewPortHandler.refresh(_zoomMatrixBuffer);
  }

  void translate(double dx, double dy) {
    Matrix4Utils.postTranslate(viewPortHandler.mMatrixTouch, dx, dy);
    viewPortHandler.limitTransAndScale(
        viewPortHandler.mMatrixTouch, viewPortHandler.mContentRect);
  }

  /// Sets the size of the area (range on the y-axis) that should be maximum
  /// visible at once.
  ///
  /// @param maxYRange the maximum visible range on the y-axis
  /// @param axis      the axis for which this limit should apply
  void setVisibleYRangeMaximum(double maxYRange, AxisDependency axis) {
    double yScale = getAxisRange(axis) / maxYRange;
    viewPortHandler.setMinimumScaleY(yScale);
  }

  /// Sets the size of the area (range on the y-axis) that should be minimum visible at once, no further zooming in possible.
  ///
  /// @param minYRange
  /// @param axis      the axis for which this limit should apply
  void setVisibleYRangeMinimum(double minYRange, AxisDependency axis) {
    double yScale = getAxisRange(axis) / minYRange;
    viewPortHandler.setMaximumScaleY(yScale);
  }

  /// Limits the maximum and minimum y range that can be visible by pinching and zooming.
  ///
  /// @param minYRange
  /// @param maxYRange
  /// @param axis
  void setVisibleYRange(
      double minYRange, double maxYRange, AxisDependency axis) {
    double minScale = getAxisRange(axis) / minYRange;
    double maxScale = getAxisRange(axis) / maxYRange;
    viewPortHandler.setMinMaxScaleY(minScale, maxScale);
  }

//  /// Sets custom offsets for the current ViewPort (the offsets on the sides of
//  /// the actual chart window). Setting this will prevent the chart from
//  /// automatically calculating it's offsets. Use resetViewPortOffsets() to
//  /// undo this. ONLY USE THIS WHEN YOU KNOW WHAT YOU ARE DOING, else use
//  /// setExtraOffsets(...).
//  ///
//  /// @param left
//  /// @param top
//  /// @param right
//  /// @param bottom
//  void setViewPortOffsets(final double left, final double top,
//      final double right, final double bottom) {
//    _customViewPortEnabled = true;
//    viewPortHandler.restrainViewPort(left, top, right, bottom);
//    prepareOffsetMatrix();
//    prepareValuePxMatrix();
//  }

  /**
   * ################ ################ ################ ################
   */
  /** CODE BELOW IS GETTERS AND SETTERS */

  /// Returns the range of the specified axis.
  ///
  /// @param axis
  /// @return
  double getAxisRange(AxisDependency axis) {
    if (axis == AxisDependency.LEFT)
      return _axisLeft.mAxisRange;
    else
      return _axisRight.mAxisRange;
  }

  List<double> mGetPositionBuffer = List(2);

  /// Returns a recyclable MPPointF instance.
  /// Returns the position (in pixels) the provided Entry has inside the chart
  /// view or null, if the provided Entry is null.
  ///
  /// @param e
  /// @return
  MPPointF getPosition(Entry e, AxisDependency axis) {
    if (e == null) return null;

    mGetPositionBuffer[0] = e.x;
    mGetPositionBuffer[1] = e.y;

    getTransformer(axis).pointValuesToPixel(mGetPositionBuffer);

    return MPPointF.getInstance1(mGetPositionBuffer[0], mGetPositionBuffer[1]);
  }

  /// Sets the color for the background of the chart-drawing area (everything
  /// behind the grid lines).
  ///
  /// @param color
  void setGridBackgroundColor(Color color) {
    _gridBackgroundPaint..color = color;
  }

  /// Sets the width of the border lines in dp.
  ///
  /// @param width
  void setBorderWidth(double width) {
    _borderPaint..strokeWidth = Utils.convertDpToPixel(width);
  }

  /// Sets the color of the chart border lines.
  ///
  /// @param color
  void setBorderColor(Color color) {
    _borderPaint..color = color;
  }

  /// Returns a recyclable MPPointD instance
  /// Returns the x and y values in the chart at the given touch point
  /// (encapsulated in a MPPointD). This method transforms pixel coordinates to
  /// coordinates / values in the chart. This is the opposite method to
  /// getPixelForValues(...).
  ///
  /// @param x
  /// @param y
  /// @return
  MPPointD getValuesByTouchPoint1(double x, double y, AxisDependency axis) {
    MPPointD result = MPPointD.getInstance1(0, 0);
    getValuesByTouchPoint2(x, y, axis, result);
    return result;
  }

  void getValuesByTouchPoint2(
      double x, double y, AxisDependency axis, MPPointD outputPoint) {
    getTransformer(axis).getValuesByTouchPoint2(x, y, outputPoint);
  }

  /// Returns a recyclable MPPointD instance
  /// Transforms the given chart values into pixels. This is the opposite
  /// method to getValuesByTouchPoint(...).
  ///
  /// @param x
  /// @param y
  /// @return
  MPPointD getPixelForValues(double x, double y, AxisDependency axis) {
    return getTransformer(axis).getPixelForValues(x, y);
  }

  /// returns the Entry object displayed at the touched position of the chart
  ///
  /// @param x
  /// @param y
  /// @return
  Entry getEntryByTouchPoint(double x, double y) {
    Highlight h = getHighlightByTouchPoint(x, y);
    if (h != null) {
      return getData().getEntryForHighlight(h);
    }
    return null;
  }

  /// returns the DataSet object displayed at the touched position of the chart
  ///
  /// @param x
  /// @param y
  /// @return
  IBarLineScatterCandleBubbleDataSet getDataSetByTouchPoint(
      double x, double y) {
    Highlight h = getHighlightByTouchPoint(x, y);
    if (h != null) {
      return getData().getDataSetByIndex(h.getDataSetIndex());
    }
    return null;
  }

  /// buffer for storing lowest visible x point
  MPPointD posForGetLowestVisibleX = MPPointD.getInstance1(0, 0);

  /// Returns the lowest x-index (value on the x-axis) that is still visible on
  /// the chart.
  ///
  /// @return
  @override
  double getLowestVisibleX() {
    getTransformer(AxisDependency.LEFT).getValuesByTouchPoint2(
        viewPortHandler.contentLeft(),
        viewPortHandler.contentBottom(),
        posForGetLowestVisibleX);
    double result = max(xAxis.mAxisMinimum, posForGetLowestVisibleX.x);
    return result;
  }

  /// buffer for storing highest visible x point
  MPPointD posForGetHighestVisibleX = MPPointD.getInstance1(0, 0);

  /// Returns the highest x-index (value on the x-axis) that is still visible
  /// on the chart.
  ///
  /// @return
  @override
  double getHighestVisibleX() {
    getTransformer(AxisDependency.LEFT).getValuesByTouchPoint2(
        viewPortHandler.contentRight(),
        viewPortHandler.contentBottom(),
        posForGetHighestVisibleX);
    double result = min(xAxis.mAxisMaximum, posForGetHighestVisibleX.x);
    return result;
  }

  /// Returns the range visible on the x-axis.
  ///
  /// @return
  double getVisibleXRange() {
    return (getHighestVisibleX() - getLowestVisibleX()).abs();
  }

  /// returns the current x-scale factor
  double getScaleX() {
    if (viewPortHandler == null)
      return 1;
    else
      return viewPortHandler.getScaleX();
  }

  /// returns the current y-scale factor
  double getScaleY() {
    if (viewPortHandler == null)
      return 1;
    else
      return viewPortHandler.getScaleY();
  }

  /// if the chart is fully zoomed out, return true
  ///
  /// @return
  bool isFullyZoomedOut() {
    return viewPortHandler.isFullyZoomedOut();
  }

  /// Returns the y-axis object to the corresponding AxisDependency. In the
  /// horizontal bar-chart, LEFT == top, RIGHT == BOTTOM
  ///
  /// @param axis
  /// @return
  YAxis getAxis(AxisDependency axis) {
    if (axis == AxisDependency.LEFT)
      return _axisLeft;
    else
      return _axisRight;
  }

  @override
  bool isInverted(AxisDependency axis) {
    return getAxis(axis).isInverted();
  }

  /// Set an offset in dp that allows the user to drag the chart over it's
  /// bounds on the x-axis.
  ///
  /// @param offset
  void setDragOffsetX(double offset) {
    viewPortHandler.setDragOffsetX(offset);
  }

  /// Set an offset in dp that allows the user to drag the chart over it's
  /// bounds on the y-axis.
  ///
  /// @param offset
  void setDragOffsetY(double offset) {
    viewPortHandler.setDragOffsetY(offset);
  }

  /// Returns true if both drag offsets (x and y) are zero or smaller.
  ///
  /// @return
  bool hasNoDragOffset() {
    return viewPortHandler.hasNoDragOffset();
  }

  @override
  double getYChartMax() {
    return max(_axisLeft.mAxisMaximum, _axisRight.mAxisMaximum);
  }

  @override
  double getYChartMin() {
    return min(_axisLeft.mAxisMinimum, _axisRight.mAxisMinimum);
  }

  @override
  int getMaxVisibleCount() {
    return _maxVisibleCount;
  }

  @override
  BarLineScatterCandleBubbleData getData() {
    return super.getData();
  }

  /// Returns true if either the left or the right or both axes are inverted.
  ///
  /// @return
  bool isAnyAxisInverted() {
    if (_axisLeft.isInverted()) return true;
    if (_axisRight.isInverted()) return true;
    return false;
  }
}
