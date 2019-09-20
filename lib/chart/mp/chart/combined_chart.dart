import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/gestures/scale.dart';
import 'package:flutter/src/gestures/tap.dart';
import 'package:mp_flutter_chart/chart/mp/chart/chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/combined_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/combined_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

class CombinedChart extends BarLineScatterCandleBubbleChart {
  bool drawValueAboveBar;
  bool highlightFullBarEnabled;
  bool drawBarShadow;
  bool fitBars;

  CombinedChart(CombinedData data,
      {IMarker marker,
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
      bool highlightFullBarEnabled = true,
      bool drawValueAboveBar = false,
      bool drawBarShadow = false,
      bool fitBars = true})
      : drawValueAboveBar = drawValueAboveBar,
        highlightFullBarEnabled = highlightFullBarEnabled,
        drawBarShadow = drawBarShadow,
        fitBars = fitBars,
        super(data,
            marker: marker,
            description: description,
            viewPortHandler: viewPortHandler,
            xAxis: xAxis,
            legend: legend,
            legendRenderer: legendRenderer,
            renderer: renderer,
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
            infoTextColor: infoTextColor,
            maxVisibleCount: maxVisibleCount,
            autoScaleMinMaxEnabled: autoScaleMinMaxEnabled,
            pinchZoomEnabled: pinchZoomEnabled,
            doubleTapToZoomEnabled: doubleTapToZoomEnabled,
            highlightPerDragEnabled: highlightPerDragEnabled,
            dragXEnabled: dragXEnabled,
            dragYEnabled: dragYEnabled,
            scaleXEnabled: scaleXEnabled,
            scaleYEnabled: scaleYEnabled,
            drawGridBackground: drawGridBackground,
            drawBorders: drawBorders,
            clipValuesToContent: clipValuesToContent,
            minOffset: minOffset,
            keepPositionOnRotation: keepPositionOnRotation,
            drawListener: drawListener,
            axisLeft: axisLeft,
            axisRight: axisRight,
            axisRendererLeft: axisRendererLeft,
            axisRendererRight: axisRendererRight,
            leftAxisTransformer: leftAxisTransformer,
            rightAxisTransformer: rightAxisTransformer,
            xAxisRenderer: xAxisRenderer,
            customViewPortEnabled: customViewPortEnabled,
            zoomMatrixBuffer: zoomMatrixBuffer,
            minXRange: minXRange,
            maxXRange: maxXRange,
            minimumScaleX: minimumScaleX,
            minimumScaleY: minimumScaleY);

  @override
  ChartState<ChartPainter<ChartData<IDataSet<Entry>>>, Chart>
      createChartState() {
    return CombinedChartState();
  }
}

class CombinedChartState
    extends ChartState<CombinedChartPainter, CombinedChart> {
  @override
  void initialPainter() {
    painter = CombinedChartPainter(
        widget.data,
        animator,
        widget.viewPortHandler,
        widget.maxHighlightDistance,
        widget.highLightPerTapEnabled,
        widget.dragDecelerationEnabled,
        widget.dragDecelerationFrictionCoef,
        widget.extraLeftOffset,
        widget.extraTopOffset,
        widget.extraRightOffset,
        widget.extraBottomOffset,
        widget.noDataText,
        widget.touchEnabled,
        widget.marker,
        widget.description,
        widget.drawMarkers,
        widget.infoPaint,
        widget.descPaint,
        widget.xAxis,
        widget.legend,
        widget.legendRenderer,
        widget.selectionListener,
        widget.maxVisibleCount,
        widget.autoScaleMinMaxEnabled,
        widget.pinchZoomEnabled,
        widget.doubleTapToZoomEnabled,
        widget.highlightPerDragEnabled,
        widget.dragXEnabled,
        widget.dragYEnabled,
        widget.scaleXEnabled,
        widget.scaleYEnabled,
        widget.gridBackgroundPaint,
        widget.borderPaint,
        widget.drawGridBackground,
        widget.drawBorders,
        widget.clipValuesToContent,
        widget.minOffset,
        widget.keepPositionOnRotation,
        widget.drawListener,
        widget.axisLeft,
        widget.axisRight,
        widget.axisRendererLeft,
        widget.axisRendererRight,
        widget.leftAxisTransformer,
        widget.rightAxisTransformer,
        widget.xAxisRenderer,
        widget.zoomMatrixBuffer,
        widget.customViewPortEnabled,
        widget.minXRange,
        widget.maxXRange,
        widget.minimumScaleX,
        widget.minimumScaleY,
        widget.highlightFullBarEnabled,
        widget.drawValueAboveBar,
        widget.drawBarShadow,
        widget.fitBars);
    painter.highlightValue6(_lastHighlighted, false);
  }

  IDataSet _closestDataSetToTouch;

  double _curX = 0.0;
  double _curY = 0.0;
  double _scaleX = -1.0;
  double _scaleY = -1.0;
  bool _isZoom = false;

  MPPointF _getTrans(double x, double y) {
    ViewPortHandler vph = painter.viewPortHandler;

    double xTrans = x - vph.offsetLeft();
    double yTrans = 0.0;

    // check if axis is inverted
    if (_inverted()) {
      yTrans = -(y - vph.offsetTop());
    } else {
      yTrans = -(painter.getMeasuredHeight() - y - vph.offsetBottom());
    }

    return MPPointF.getInstance1(xTrans, yTrans);
  }

  bool _inverted() {
    return (_closestDataSetToTouch == null && painter.isAnyAxisInverted()) ||
        (_closestDataSetToTouch != null &&
            painter.isInverted(_closestDataSetToTouch.getAxisDependency()));
  }

  @override
  void onTapDown(TapDownDetails detail) {
    _curX = detail.localPosition.dx;
    _curY = detail.localPosition.dy;
    _closestDataSetToTouch = painter.getDataSetByTouchPoint(
        detail.localPosition.dx, detail.localPosition.dy);
  }

  @override
  void onDoubleTap() {
    if (painter.doubleTapToZoomEnabled &&
        painter.getData().getEntryCount() > 0) {
      MPPointF trans = _getTrans(_curX, _curY);
      painter.zoom(painter.scaleXEnabled ? 1.4 : 1,
          painter.scaleYEnabled ? 1.4 : 1, trans.x, trans.y);
//      painter.getOnChartGestureListener()?.onChartDoubleTapped(_curX, _curY);
      setState(() {});
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
      if (painter.dragYEnabled && painter.dragXEnabled) {
        painter.translate(dx, dy);
        _dragHighlight(
            Offset(detail.localFocalPoint.dx, detail.localFocalPoint.dy));
//        listener?.onChartTranslate(
//            detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
        setState(() {});
      } else {
        if (painter.dragXEnabled) {
          painter.translate(dx, 0.0);
          _dragHighlight(Offset(detail.localFocalPoint.dx, 0.0));
//          listener?.onChartTranslate(
//              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
          setState(() {});
        } else if (painter.dragYEnabled) {
          if (_inverted()) {
            // if there is an inverted horizontalbarchart
//      if (mChart instanceof HorizontalBarChart) {
//        dx = -dx;
//      } else {
            dy = -dy;
//      }
          }
          painter.translate(0.0, dy);
          _dragHighlight(Offset(0.0, detail.localFocalPoint.dy));
//          listener?.onChartTranslate(
//              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
          setState(() {});
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

      scaleX = painter.scaleXEnabled ? scaleX : 1.0;
      scaleY = painter.scaleYEnabled ? scaleY : 1.0;
      painter.zoom(scaleX, scaleY, trans.x, trans.y);
//      listener?.onChartScale(
//          detail.localFocalPoint.dx, detail.localFocalPoint.dy, scaleX, scaleY);
      setState(() {});
      MPPointF.recycleInstance(trans);
    }
    _scaleX = detail.horizontalScale;
    _scaleY = detail.verticalScale;
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
  }

  void _dragHighlight(Offset offset) {
    if (painter.highlightPerDragEnabled) {
      Highlight h = painter.getHighlightByTouchPoint(offset.dx, offset.dy);
      if (h != null && !h.equalTo(_lastHighlighted)) {
        _lastHighlighted = h;
        painter.highlightValue6(h, true);
      }
    } else {
      _lastHighlighted = null;
    }
  }

  Highlight _lastHighlighted;

  @override
  void onSingleTapUp(TapUpDetails detail) {
    if (painter.highlightPerDragEnabled) {
      Highlight h = painter.getHighlightByTouchPoint(
          detail.localPosition.dx, detail.localPosition.dy);
      _lastHighlighted =
          HighlightUtils.performHighlight(painter, h, _lastHighlighted);
//      painter.getOnChartGestureListener()?.onChartSingleTapped(
//          detail.localPosition.dx, detail.localPosition.dy);
      setState(() {});
    } else {
      _lastHighlighted = null;
    }
  }
}

typedef InitCombinedChartPainterCallback = void Function(
    CombinedChartPainter painter);
