import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_redar_chart_painter.dart';

abstract class PieRadarHighlighter<T extends PieRadarChartPainter>
    implements IHighlighter {
  T mChart;

  /// buffer for storing previously highlighted values
  List<Highlight> mHighlightBuffer = List();

  PieRadarHighlighter(T chart) {
    this.mChart = chart;
  }

  @override
  Highlight getHighlight(double x, double y) {
    double touchDistanceToCenter = mChart.distanceToCenter(x, y);

    // check if a slice was touched
    if (touchDistanceToCenter > mChart.getRadius()) {
      // if no slice was touched, highlight nothing
      return null;
    } else {
      double angle = mChart.getAngleForPoint(x, y);

      if (mChart is PieChartPainter) {
        angle /= mChart.mAnimator.getPhaseY();
      }

      int index = mChart.getIndexForAngle(angle);

      // check if the index could be found
      if (index < 0 ||
          index >= mChart.getData().getMaxEntryCountSet().getEntryCount()) {
        return null;
      } else {
        return getClosestHighlight(index, x, y);
      }
    }
  }

  /// Returns the closest Highlight object of the given objects based on the touch position inside the chart.
  ///
  /// @param index
  /// @param x
  /// @param y
  /// @return
  Highlight getClosestHighlight(int index, double x, double y);
}
