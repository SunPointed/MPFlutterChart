import 'package:flutter/widgets.dart';
import 'package:mp_chart/mp/chart/chart.dart';
import 'package:mp_chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_chart/mp/core/axis/y_axis.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/chart_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/functions.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/marker/i_marker.dart';
import 'package:mp_chart/mp/core/poolable/point.dart';
import 'package:mp_chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_chart/mp/core/transformer/transformer.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_chart/mp/core/utils/utils.dart';
import 'package:mp_chart/mp/core/view_port.dart';
import 'package:mp_chart/mp/painter/bar_line_chart_painter.dart';

abstract class BarLineScatterCandleBubbleChart<
    P extends BarLineChartBasePainter> extends Chart<P> {
  int maxVisibleCount;
  bool autoScaleMinMaxEnabled;
  bool pinchZoomEnabled;
  bool doubleTapToZoomEnabled;
  bool highlightPerDragEnabled;
  bool dragXEnabled;
  bool dragYEnabled;
  bool scaleXEnabled;
  bool scaleYEnabled;
  bool drawGridBackground;
  bool drawBorders;
  bool clipValuesToContent;
  double minOffset;
  bool keepPositionOnRotation;
  OnDrawListener drawListener;
  YAxis axisLeft;
  YAxis axisRight;
  YAxisRenderer axisRendererLeft;
  YAxisRenderer axisRendererRight;
  Transformer leftAxisTransformer;
  Transformer rightAxisTransformer;
  XAxisRenderer xAxisRenderer;
  bool customViewPortEnabled;
  Matrix4 zoomMatrixBuffer;
  double minXRange;
  double maxXRange;
  double minimumScaleX;
  double minimumScaleY;

  //////
  Paint gridBackgroundPaint;
  Paint borderPaint;

  Color backgroundColor;
  Color borderColor;
  double borderStrokeWidth;

  AxisLeftSettingFunction _axisLeftSettingFunction;
  AxisRightSettingFunction _axisRightSettingFunction;

  BarLineScatterCandleBubbleChart(
    ChartData<IDataSet<Entry>> data, {
    IMarker marker,
    Description description,
    AxisLeftSettingFunction axisLeftSettingFunction,
    AxisRightSettingFunction axisRightSettingFunction,
    XAxisSettingFunction xAxisSettingFunction,
    LegendSettingFunction legendSettingFunction,
    DataRendererSettingFunction rendererSettingFunction,
    OnChartValueSelectedListener selectionListener,
    Color backgroundColor,
    Color borderColor,
    double borderStrokeWidth = 1.0,
    int maxVisibleCount = 100,
    bool autoScaleMinMaxEnabled = true,
    bool pinchZoomEnabled = true,
    bool doubleTapToZoomEnabled = true,
    bool highlightPerDragEnabled = true,
    bool dragXEnabled = true,
    bool dragYEnabled = true,
    bool scaleXEnabled = true,
    bool scaleYEnabled = true,
    bool drawGridBackground = false,
    bool drawBorders = false,
    bool clipValuesToContent = false,
    double minOffset = 30,
    bool keepPositionOnRotation = false,
    bool customViewPortEnabled = false,
    double minXRange = 1.0,
    double maxXRange = 1.0,
    double minimumScaleX = 1.0,
    double minimumScaleY = 1.0,
    double maxHighlightDistance = 100.0,
    bool highLightPerTapEnabled = true,
    double extraTopOffset = 0.0,
    double extraRightOffset = 0.0,
    double extraBottomOffset = 0.0,
    double extraLeftOffset = 0.0,
    bool drawMarkers = true,
    double descTextSize = 12,
    double infoTextSize = 12,
    Color descTextColor,
    Color infoTextColor,
    OnDrawListener drawListener,
    String noDataText = "No chart data available.",
    YAxis axisLeft,
    YAxis axisRight,
    YAxisRenderer axisRendererLeft,
    YAxisRenderer axisRendererRight,
    Transformer leftAxisTransformer,
    Transformer rightAxisTransformer,
    XAxisRenderer xAxisRenderer,
    Matrix4 zoomMatrixBuffer,
  })  : maxVisibleCount = maxVisibleCount,
        autoScaleMinMaxEnabled = autoScaleMinMaxEnabled,
        pinchZoomEnabled = pinchZoomEnabled,
        doubleTapToZoomEnabled = doubleTapToZoomEnabled,
        highlightPerDragEnabled = highlightPerDragEnabled,
        dragXEnabled = dragXEnabled,
        dragYEnabled = dragYEnabled,
        scaleXEnabled = scaleXEnabled,
        scaleYEnabled = scaleYEnabled,
        drawGridBackground = drawGridBackground,
        drawBorders = drawBorders,
        clipValuesToContent = clipValuesToContent,
        minOffset = minOffset,
        keepPositionOnRotation = keepPositionOnRotation,
        drawListener = drawListener,
        axisLeft = axisLeft,
        axisRight = axisRight,
        axisRendererLeft = axisRendererLeft,
        axisRendererRight = axisRendererRight,
        leftAxisTransformer = leftAxisTransformer,
        rightAxisTransformer = rightAxisTransformer,
        xAxisRenderer = xAxisRenderer,
        customViewPortEnabled = customViewPortEnabled,
        zoomMatrixBuffer = zoomMatrixBuffer,
        minXRange = minXRange,
        maxXRange = maxXRange,
        minimumScaleX = minimumScaleX,
        minimumScaleY = minimumScaleY,
        backgroundColor = backgroundColor,
        borderColor = borderColor,
        borderStrokeWidth = borderStrokeWidth,
        _axisLeftSettingFunction = axisLeftSettingFunction,
        _axisRightSettingFunction = axisRightSettingFunction,
        super(data,
            marker: marker,
            description: description,
            noDataText: noDataText,
            xAxisSettingFunction: xAxisSettingFunction,
            legendSettingFunction: legendSettingFunction,
            rendererSettingFunction: rendererSettingFunction,
            selectionListener: selectionListener,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            extraLeftOffset: extraLeftOffset,
            drawMarkers: drawMarkers,
            descTextSize: descTextSize,
            infoTextSize: infoTextSize,
            descTextColor: descTextColor,
            infoTextColor: infoTextColor);

  @override
  void doneBeforePainterInit() {
    super.doneBeforePainterInit();
    gridBackgroundPaint = Paint()
      ..color = backgroundColor == null
          ? Color.fromARGB(255, 240, 240, 240)
          : backgroundColor
      ..style = PaintingStyle.fill;

    borderPaint = Paint()
      ..color = borderColor == null ? ColorUtils.BLACK : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = Utils.convertDpToPixel(borderStrokeWidth);

    this.drawListener ??= initDrawListener();
    this.axisLeft = initAxisLeft();
    this.axisRight = initAxisRight();
    this.leftAxisTransformer ??= initLeftAxisTransformer();
    this.rightAxisTransformer ??= initRightAxisTransformer();
    this.zoomMatrixBuffer ??= initZoomMatrixBuffer();
    this.axisRendererLeft = initAxisRendererLeft();
    this.axisRendererRight = initAxisRendererRight();
    this.xAxisRenderer = initXAxisRenderer();
    if (_axisLeftSettingFunction != null) {
      _axisLeftSettingFunction(axisLeft, this);
    }
    if (_axisRightSettingFunction != null) {
      _axisRightSettingFunction(axisRight, this);
    }
  }

  OnDrawListener initDrawListener() {
    return null;
  }

  YAxis initAxisLeft() => YAxis(position: AxisDependency.LEFT);

  YAxis initAxisRight() => YAxis(position: AxisDependency.RIGHT);

  Transformer initLeftAxisTransformer() => Transformer(viewPortHandler);

  Transformer initRightAxisTransformer() => Transformer(viewPortHandler);

  YAxisRenderer initAxisRendererLeft() =>
      YAxisRenderer(viewPortHandler, axisLeft, leftAxisTransformer);

  YAxisRenderer initAxisRendererRight() =>
      YAxisRenderer(viewPortHandler, axisRight, rightAxisTransformer);

  XAxisRenderer initXAxisRenderer() =>
      XAxisRenderer(viewPortHandler, xAxis, leftAxisTransformer);

  Matrix4 initZoomMatrixBuffer() => Matrix4.identity();

  BarLineChartBasePainter get painter => super.painter;

  void setViewPortOffsets(final double left, final double top,
      final double right, final double bottom) {
    customViewPortEnabled = true;
    viewPortHandler.restrainViewPort(left, top, right, bottom);
  }
}

abstract class BarLineScatterCandleBubbleState<
    T extends BarLineScatterCandleBubbleChart> extends ChartState<T> {
  IDataSet _closestDataSetToTouch;

  Highlight lastHighlighted;
  double _curX = 0.0;
  double _curY = 0.0;
  double _scaleX = -1.0;
  double _scaleY = -1.0;
  bool _isZoom = false;

  MPPointF _getTrans(double x, double y) {
    ViewPortHandler vph = widget.painter.viewPortHandler;

    double xTrans = x - vph.offsetLeft();
    double yTrans = 0.0;

    // check if axis is inverted
    if (_inverted()) {
      yTrans = -(y - vph.offsetTop());
    } else {
      yTrans = -(widget.painter.getMeasuredHeight() - y - vph.offsetBottom());
    }

    return MPPointF.getInstance1(xTrans, yTrans);
  }

  bool _inverted() {
    return (_closestDataSetToTouch == null &&
            widget.painter.isAnyAxisInverted()) ||
        (_closestDataSetToTouch != null &&
            widget.painter
                .isInverted(_closestDataSetToTouch.getAxisDependency()));
  }

  @override
  void onTapDown(TapDownDetails detail) {
    _curX = detail.localPosition.dx;
    _curY = detail.localPosition.dy;
    _closestDataSetToTouch = widget.painter.getDataSetByTouchPoint(
        detail.localPosition.dx, detail.localPosition.dy);
  }

  @override
  void onDoubleTap() {
    if (widget.painter.doubleTapToZoomEnabled &&
        widget.painter.getData().getEntryCount() > 0) {
      MPPointF trans = _getTrans(_curX, _curY);
      widget.painter.zoom(widget.painter.scaleXEnabled ? 1.4 : 1,
          widget.painter.scaleYEnabled ? 1.4 : 1, trans.x, trans.y);
//      painter.getOnChartGestureListener()?.onChartDoubleTapped(_curX, _curY);
      setStateIfNotDispose();
      MPPointF.recycleInstance(trans);
    }
  }

  @override
  void onScaleEnd(ScaleEndDetails detail) {
    if (_isZoom) {
      _isZoom = false;
    }
    _scaleX = -1.0;
    _scaleY = -1.0;
  }

  @override
  void onScaleStart(ScaleStartDetails detail) {
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails detail) {
    if (_scaleX == -1.0 && _scaleY == -1.0) {
      _scaleX = detail.horizontalScale;
      _scaleY = detail.verticalScale;
      return;
    }

//    OnChartGestureListener listener = painter.getOnChartGestureListener();
    if (_scaleX == detail.horizontalScale && _scaleY == detail.verticalScale) {
      if (_isZoom) {
        return;
      }

      var dx = detail.localFocalPoint.dx - _curX;
      var dy = detail.localFocalPoint.dy - _curY;
      if (widget.painter.dragYEnabled && widget.painter.dragXEnabled) {
        widget.painter.translate(dx, dy);
        _dragHighlight(
            Offset(detail.localFocalPoint.dx, detail.localFocalPoint.dy));
//        listener?.onChartTranslate(
//            detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
        setStateIfNotDispose();
      } else {
        if (widget.painter.dragXEnabled) {
          widget.painter.translate(dx, 0.0);
          _dragHighlight(Offset(detail.localFocalPoint.dx, 0.0));
//          listener?.onChartTranslate(
//              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
          setStateIfNotDispose();
        } else if (widget.painter.dragYEnabled) {
          if (_inverted()) {
            // if there is an inverted horizontalbarchart
            if (widget is HorizontalBarChart) {
              dx = -dx;
            } else {
              dy = -dy;
            }
          }
          widget.painter.translate(0.0, dy);
          _dragHighlight(Offset(0.0, detail.localFocalPoint.dy));
//          listener?.onChartTranslate(
//              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
          setStateIfNotDispose();
        }
      }
      _curX = detail.localFocalPoint.dx;
      _curY = detail.localFocalPoint.dy;
    } else {
      var scaleX = detail.horizontalScale / _scaleX;
      var scaleY = detail.verticalScale / _scaleY;

      if (!_isZoom) {
        scaleX = detail.horizontalScale;
        scaleY = detail.verticalScale;
        _isZoom = true;
      }

      MPPointF trans = _getTrans(_curX, _curY);

      scaleX = widget.painter.scaleXEnabled ? scaleX : 1.0;
      scaleY = widget.painter.scaleYEnabled ? scaleY : 1.0;
      widget.painter.zoom(scaleX, scaleY, trans.x, trans.y);
//      listener?.onChartScale(
//          detail.localFocalPoint.dx, detail.localFocalPoint.dy, scaleX, scaleY);
      setStateIfNotDispose();
      MPPointF.recycleInstance(trans);
    }
    _scaleX = detail.horizontalScale;
    _scaleY = detail.verticalScale;
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
  }

  void _dragHighlight(Offset offset) {
    if (widget.painter.highlightPerDragEnabled) {
      Highlight h =
          widget.painter.getHighlightByTouchPoint(offset.dx, offset.dy);
      if (h != null && !h.equalTo(lastHighlighted)) {
        lastHighlighted = h;
        widget.painter.highlightValue6(h, true);
      }
    } else {
      lastHighlighted = null;
    }
  }

  @override
  void onSingleTapUp(TapUpDetails detail) {
    if (widget.painter.highLightPerTapEnabled) {
      Highlight h = widget.painter.getHighlightByTouchPoint(
          detail.localPosition.dx, detail.localPosition.dy);
      lastHighlighted =
          HighlightUtils.performHighlight(widget.painter, h, lastHighlighted);
//      painter.getOnChartGestureListener()?.onChartSingleTapped(
//          detail.localPosition.dx, detail.localPosition.dy);
      setStateIfNotDispose();
    } else {
      lastHighlighted = null;
    }
  }
}
