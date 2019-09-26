import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/functions.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

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
  XAxisSettingFunction _xAxisSettingFunction;
  LegendSettingFunction _legendSettingFunction;
  DataRendererSettingFunction rendererSettingFunction;

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
      XAxisSettingFunction xAxisSettingFunction,
      LegendSettingFunction legendSettingFunction,
      DataRendererSettingFunction rendererSettingFunction,
      OnChartValueSelectedListener selectionListener,
      double maxHighlightDistance = 100.0,
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
        _xAxisSettingFunction = xAxisSettingFunction,
        _legendSettingFunction = legendSettingFunction,
        rendererSettingFunction = rendererSettingFunction,
        selectionListener = selectionListener {
    if (descTextColor == null) {
      descTextColor = ColorUtils.BLACK;
    }
    descPaint = PainterUtils.create(null, null, descTextColor, descTextSize,
        fontFamily: description?.typeface?.fontFamily,
        fontWeight: description?.typeface?.fontWeight);
    if (infoTextColor == null) {
      infoTextColor = ColorUtils.BLACK;
    }
    infoPaint = PainterUtils.create(null, null, infoTextColor, infoTextSize);

    if (maxHighlightDistance == 0.0) {
      maxHighlightDistance = Utils.convertDpToPixel(500);
    }

    this.viewPortHandler ??= initViewPortHandler();
    this.marker ??= initMarker();
    this.description ??= initDescription();
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

  void doneBeforePainterInit() {
    this.legend = initLegend();
    this.legendRenderer = initLegendRenderer();
    xAxis = initXAxis();
    if (_legendSettingFunction != null) {
      _legendSettingFunction(legend, this);
    }
    if (_xAxisSettingFunction != null) {
      _xAxisSettingFunction(xAxis, this);
    }
  }

  void initialPainter();
}

abstract class ChartState<T extends Chart> extends State<T> {
  bool _singleTap = false;

  void setStateIfNotDispose() {
    if (mounted) {
      setState(() {});
    }
  }

  void updatePainter();

  @override
  Widget build(BuildContext context) {
    widget.doneBeforePainterInit();
    widget.initialPainter();
    updatePainter();
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
