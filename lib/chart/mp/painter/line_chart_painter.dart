import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/rendering/custom_paint.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/line_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/line_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

import 'package:mp_flutter_chart/chart/mp/painter/bar_line_chart_painter.dart';

class LineChartPainter extends BarLineChartBasePainter<LineData>
    implements LineDataProvider {
  LineChartPainter(LineData data,
      {ViewPortHandler viewPortHandler = null,
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
      : super(data,
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
    mRenderer = LineChartRenderer(this, mAnimator, mViewPortHandler);
  }

  @override
  LineData getLineData() {
    return mData;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
