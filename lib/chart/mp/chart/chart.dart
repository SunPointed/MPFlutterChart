import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_line_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_redar_chart_painter.dart';

abstract class Chart<P extends ChartPainter> extends StatefulWidget
    implements AnimatorUpdateListener {
  ////// needed
  ChartData data;
  IMarker marker;
  Description description;
  ViewPortHandler viewPortHandler;
  XAxis xAxis;
  Legend legend;
  LegendRenderer legendRenderer;
  OnChartValueSelectedListener selectionListener;

  ////// option
  double maxHighlightDistance;
  bool highLightPerTapEnabled;
  bool dragDecelerationEnabled;
  double dragDecelerationFrictionCoef;
  double extraTopOffset, extraRightOffset, extraBottomOffset, extraLeftOffset;
  String noDataText;
  bool touchEnabled;
  bool drawMarkers;

  ////// split child property
  TextPainter descPaint;
  TextPainter infoPaint;

  ChartState _state;

  P _painter;
  ChartAnimator animator;

  ChartState getState() {
    return _state;
  }

  ChartState createChartState();

  @override
  State createState() {
    _state = createChartState();
    return _state;
  }

  Chart(ChartData data,
      {IMarker marker,
      Description description,
      ViewPortHandler viewPortHandler,
      XAxis xAxis,
      Legend legend,
      LegendRenderer legendRenderer,
      OnChartValueSelectedListener selectionListener,
      double maxHighlightDistance = 0.0,
      bool highLightPerTapEnabled = true,
      bool dragDecelerationEnabled = true,
      double dragDecelerationFrictionCoef = 0.9,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      double extraLeftOffset = 0.0,
      String noDataText = "No chart data available.",
      bool touchEnabled = true,
      bool drawMarkers = true,
      double descTextSize = 12,
      double infoTextSize = 12,
      Color descTextColor,
      Color infoTextColor})
      : data = data,
        maxHighlightDistance = maxHighlightDistance,
        highLightPerTapEnabled = highLightPerTapEnabled,
        dragDecelerationEnabled = dragDecelerationEnabled,
        dragDecelerationFrictionCoef = dragDecelerationFrictionCoef,
        extraLeftOffset = extraLeftOffset,
        extraTopOffset = extraTopOffset,
        extraRightOffset = extraRightOffset,
        extraBottomOffset = extraBottomOffset,
        noDataText = noDataText,
        touchEnabled = touchEnabled,
        drawMarkers = drawMarkers,
        marker = marker,
        description = description,
        viewPortHandler = viewPortHandler,
        xAxis = xAxis,
        legend = legend,
        legendRenderer = legendRenderer,
        selectionListener = selectionListener {
    if (descTextColor == null) {
      descTextColor = ColorUtils.BLACK;
    }
    descPaint = PainterUtils.create(null, null, descTextColor, descTextSize);
    if (infoTextColor == null) {
      infoTextColor = ColorUtils.BLACK;
    }
    infoPaint = PainterUtils.create(null, null, infoTextColor, infoTextSize);

    if (maxHighlightDistance == 0.0) {
      maxHighlightDistance = Utils.convertDpToPixel(500);
    }

    this.viewPortHandler ??= initViewPortHandler();
    this.legend ??= initLegend();
    this.marker ??= initMarker();
    this.description ??= initDescription();
    this.xAxis ??= initXAxis();
    this.legendRenderer ??= initLegendRenderer();
    this.selectionListener ??= initSelectionListener();

    this.animator = ChartAnimator(this);

    doneBeforePainterInit();
    initialPainter();
  }

  @override
  void onAnimationUpdate(double x, double y) {
    _state?.setStateIfNotDispose();
  }

  @override
  void onRotateUpdate(double angle) {}

  IMarker initMarker() => null;

  Description initDescription() => Description();

  ViewPortHandler initViewPortHandler() => ViewPortHandler();

  XAxis initXAxis() => XAxis();

  Legend initLegend() => Legend();

  LegendRenderer initLegendRenderer() =>
      LegendRenderer(viewPortHandler, legend);

  OnChartValueSelectedListener initSelectionListener() => null;

  ChartPainter get painter => _painter;

  set painter(P value) {
    _painter = value;
  }

  void doneBeforePainterInit();

  void initialPainter();
}

abstract class ChartState<T extends Chart> extends State<T> {
  bool _singleTap = false;

  @override
  void onRotateUpdate(double angle) {}

  void setStateIfNotDispose() {
    if (mounted) {
      setState(() {});
    }
  }

  void updatePainter();

  @override
  Widget build(BuildContext context) {
    return Stack(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: [
          ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: double.infinity, minWidth: double.infinity),
              child: GestureDetector(
                  onTapDown: (detail) {
                    _singleTap = true;
                    onTapDown(detail);
                  },
                  onTapUp: (detail) {
                    if (_singleTap) {
                      _singleTap = false;
                      onSingleTapUp(detail);
                    }
                  },
                  onDoubleTap: () {
                    _singleTap = false;
                    onDoubleTap();
                  },
                  onScaleStart: (detail) {
                    onScaleStart(detail);
                  },
                  onScaleUpdate: (detail) {
                    _singleTap = false;
                    onScaleUpdate(detail);
                  },
                  onScaleEnd: (detail) {
                    onScaleEnd(detail);
                  },
                  child: CustomPaint(painter: widget.painter))),
        ]);
  }

  @override
  void reassemble() {
    super.reassemble();
    widget.animator?.reset();
    widget.painter?.reassemble();
  }

  void onDoubleTap();

  void onScaleStart(ScaleStartDetails detail);

  void onScaleUpdate(ScaleUpdateDetails detail);

  void onScaleEnd(ScaleEndDetails detail);

  void onTapDown(TapDownDetails detail);

  void onSingleTapUp(TapUpDetails detail);
}

abstract class PieRadarChart<P extends PieRadarChartPainter> extends Chart<P> {
  double rotationAngle;
  double rawRotationAngle;
  bool rotateEnabled;
  double minOffset;

  PieRadarChart(ChartData<IDataSet<Entry>> data,
      {IMarker marker,
      Description description,
      ViewPortHandler viewPortHandler,
      XAxis xAxis,
      Legend legend,
      LegendRenderer legendRenderer,
      DataRenderer renderer,
      OnChartValueSelectedListener selectionListener,
      double rotationAngle = 270,
      double rawRotationAngle = 270,
      bool rotateEnabled = true,
      double minOffset = 30.0,
      double maxHighlightDistance = 0.0,
      bool highLightPerTapEnabled = true,
      bool dragDecelerationEnabled = true,
      double dragDecelerationFrictionCoef = 0.9,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      double extraLeftOffset = 0.0,
      String noDataText = "No chart data available.",
      bool touchEnabled = true,
      bool drawMarkers = true,
      double descTextSize = 12,
      double infoTextSize = 12,
      Color descTextColor,
      Color infoTextColor})
      : rotationAngle = rotationAngle,
        rawRotationAngle = rawRotationAngle,
        rotateEnabled = rotateEnabled,
        minOffset = minOffset,
        super(data,
            marker: marker,
            description: description,
            viewPortHandler: viewPortHandler,
            xAxis: xAxis,
            legend: legend,
            legendRenderer: legendRenderer,
            selectionListener: selectionListener,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            dragDecelerationEnabled: dragDecelerationEnabled,
            dragDecelerationFrictionCoef: dragDecelerationFrictionCoef,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            extraLeftOffset: extraLeftOffset,
            noDataText: noDataText,
            touchEnabled: touchEnabled,
            drawMarkers: drawMarkers,
            descTextSize: descTextSize,
            infoTextSize: infoTextSize,
            descTextColor: descTextColor,
            infoTextColor: infoTextColor);

  @override
  void doneBeforePainterInit() {}

  PieRadarChartPainter get painter => super.painter;
}

abstract class PieRadarChartState<T extends PieRadarChart>
    extends ChartState<T> {
  Highlight lastHighlighted;
  MPPointF _touchStartPoint = MPPointF.getInstance1(0, 0);
  double _startAngle = 0.0;

  void _setGestureStartAngle(double x, double y) {
    _startAngle = widget.painter.getAngleForPoint(x, y) -
        widget.painter.getRawRotationAngle();
  }

  void _updateGestureRotation(double x, double y) {
    double angle = widget.painter.getAngleForPoint(x, y) - _startAngle;
    widget.rawRotationAngle = angle;
    widget.rotationAngle = Utils.getNormalizedAngle(widget.rawRotationAngle);
  }

  @override
  void onRotateUpdate(double angle) {
    widget.rawRotationAngle = angle;
    widget.rotationAngle = Utils.getNormalizedAngle(widget.rawRotationAngle);
    setState(() {});
  }

  @override
  void onDoubleTap() {}

  @override
  void onScaleEnd(ScaleEndDetails detail) {}

  @override
  void onScaleStart(ScaleStartDetails detail) {
    _setGestureStartAngle(detail.localFocalPoint.dx, detail.localFocalPoint.dy);
    _touchStartPoint
      ..x = detail.localFocalPoint.dx
      ..y = detail.localFocalPoint.dy;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails detail) {
    _updateGestureRotation(
        detail.localFocalPoint.dx, detail.localFocalPoint.dy);
    setStateIfNotDispose();
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

  @override
  void onTapDown(TapDownDetails detail) {}
}

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

  BarLineScatterCandleBubbleChart(
    ChartData<IDataSet<Entry>> data, {
    IMarker marker,
    Description description,
    ViewPortHandler viewPortHandler,
    XAxis xAxis,
    Legend legend,
    LegendRenderer legendRenderer,
    DataRenderer renderer,
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
    double maxHighlightDistance = 0.0,
    bool highLightPerTapEnabled = true,
    bool dragDecelerationEnabled = true,
    double dragDecelerationFrictionCoef = 0.9,
    double extraTopOffset = 0.0,
    double extraRightOffset = 0.0,
    double extraBottomOffset = 0.0,
    double extraLeftOffset = 0.0,
    String noDataText = "No chart data available.",
    bool touchEnabled = true,
    bool drawMarkers = true,
    double descTextSize = 12,
    double infoTextSize = 12,
    Color descTextColor,
    Color infoTextColor,
    OnDrawListener drawListener,
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
        super(data,
            marker: marker,
            description: description,
            viewPortHandler: viewPortHandler,
            xAxis: xAxis,
            legend: legend,
            legendRenderer: legendRenderer,
            selectionListener: selectionListener,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            dragDecelerationEnabled: dragDecelerationEnabled,
            dragDecelerationFrictionCoef: dragDecelerationFrictionCoef,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            extraLeftOffset: extraLeftOffset,
            noDataText: noDataText,
            touchEnabled: touchEnabled,
            drawMarkers: drawMarkers,
            descTextSize: descTextSize,
            infoTextSize: infoTextSize,
            descTextColor: descTextColor,
            infoTextColor: infoTextColor);

  @override
  void doneBeforePainterInit() {
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
    this.axisLeft ??= initAxisLeft();
    this.axisRight ??= initAxisRight();
    this.leftAxisTransformer ??= initLeftAxisTransformer();
    this.rightAxisTransformer ??= initRightAxisTransformer();
    this.zoomMatrixBuffer ??= initZoomMatrixBuffer();
    this.axisRendererLeft ??= initAxisRendererLeft();
    this.axisRendererRight ??= initAxisRendererRight();
    this.xAxisRenderer ??= initXAxisRenderer();
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
