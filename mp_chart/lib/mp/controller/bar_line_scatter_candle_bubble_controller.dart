import 'package:flutter/rendering.dart';
import 'package:mp_chart/mp/chart/bar_line_scatter_candle_bubble_chart.dart';
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
  bool pinchZoomEnabled;
  bool keepPositionOnRotation;

  //////
  Paint gridBackgroundPaint;
  Paint borderPaint;

  Paint backgroundPaint;
  Color gridBackColor;
  Color borderColor;
  Color backgroundColor;
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
    this.pinchZoomEnabled = true,
    this.keepPositionOnRotation = false,
    this.gridBackgroundPaint,
    this.borderPaint,
    this.backgroundPaint,
    this.gridBackColor,
    this.borderColor,
    this.backgroundColor,
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

  BarLineScatterCandleBubbleChart get chart => super.chart;

  /**
   * Moves the left side of the current viewport to the specified x-position.
   * This also refreshes the chart by calling invalidate().
   *
   * @param xValue
   */
  void moveViewToX(double xValue) {
    List<double> pts = List();
    pts.add(xValue);
    pts.add(0.0);

    chart?.painter
        ?.getTransformer(AxisDependency.LEFT)
        ?.pointValuesToPixel(pts);
    viewPortHandler.centerViewPort(pts);
  }

  /**
   * This will move the left side of the current viewport to the specified
   * x-value on the x-axis, and center the viewport to the specified y value on the y-axis.
   * This also refreshes the chart by calling invalidate().
   *
   * @param xValue
   * @param yValue
   * @param axis   - which axis should be used as a reference for the y-axis
   */
  void moveViewTo(double xValue, double yValue, AxisDependency axis) {
    List<double> pts = List();
    pts.add(xValue);
    pts.add(yValue);

    chart?.painter
        ?.getTransformer(axis)
        ?.pointValuesToPixel(pts);
    viewPortHandler.centerViewPort(pts);
  }

  /**
   * Sets the size of the area (range on the x-axis) that should be maximum
   * visible at once (no further zooming out allowed). If this is e.g. set to
   * 10, no more than a range of 10 on the x-axis can be viewed at once without
   * scrolling.
   *
   * @param maxXRange The maximum visible range of x-values.
   */
  void setVisibleXRangeMaximum(double maxXRange) {
    double xScale = xAxis.axisRange / (maxXRange);
    viewPortHandler.setMinimumScaleX(xScale);
  }
}
