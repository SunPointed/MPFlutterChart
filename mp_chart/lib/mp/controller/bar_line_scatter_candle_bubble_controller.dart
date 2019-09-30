import 'package:flutter/rendering.dart';
import 'package:mp_chart/mp/controller/controller.dart';
import 'package:mp_chart/mp/core/axis/y_axis.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/functions.dart';
import 'package:mp_chart/mp/core/marker/i_marker.dart';
import 'package:mp_chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_chart/mp/core/transformer/transformer.dart';

class BarLineScatterCandleBubbleController extends Controller {
  int maxVisibleCount;
  bool autoScaleMinMaxEnabled;
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
  bool pinchZoomEnabled;
  bool keepPositionOnRotation;

  //////
  Paint gridBackgroundPaint;
  Paint borderPaint;

  Color backgroundColor;
  Color borderColor;
  double borderStrokeWidth;

  AxisLeftSettingFunction axisLeftSettingFunction;
  AxisRightSettingFunction axisRightSettingFunction;

  BarLineScatterCandleBubbleController({
    this.maxVisibleCount = 100,
    this.autoScaleMinMaxEnabled = true,
    this.doubleTapToZoomEnabled = true,
    this.highlightPerDragEnabled = true,
    this.dragXEnabled = true,
    this.dragYEnabled = true,
    this.scaleXEnabled = true,
    this.scaleYEnabled = true,
    this.drawGridBackground = false,
    this.drawBorders = false,
    this.clipValuesToContent = false,
    this.minOffset = 30.0,
    this.drawListener,
    this.axisLeft,
    this.axisRight,
    this.axisRendererLeft,
    this.axisRendererRight,
    this.leftAxisTransformer,
    this.rightAxisTransformer,
    this.xAxisRenderer,
    this.customViewPortEnabled = false,
    this.zoomMatrixBuffer,
    this.minXRange = 1.0,
    this.maxXRange = 1.0,
    this.minimumScaleX = 1.0,
    this.minimumScaleY = 1.0,
    this.pinchZoomEnabled = true,
    this.keepPositionOnRotation = false,
    this.gridBackgroundPaint,
    this.borderPaint,
    this.backgroundColor,
    this.borderColor,
    this.borderStrokeWidth = 1.0,
    this.axisLeftSettingFunction,
    this.axisRightSettingFunction,
    IMarker marker,
    Description description,
    String noDataText = "No chart data available.",
    XAxisSettingFunction xAxisSettingFunction,
    LegendSettingFunction legendSettingFunction,
    DataRendererSettingFunction rendererSettingFunction,
    OnChartValueSelectedListener selectionListener,
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
  }) : super(
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
}
