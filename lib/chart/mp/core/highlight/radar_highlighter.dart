import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/pie_radar_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/radar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class RadarHighlighter extends PieRadarHighlighter<RadarChartPainter> {
  RadarHighlighter(RadarChartPainter chart) : super(chart);

  @override
  Highlight getClosestHighlight(int index, double x, double y) {
    List<Highlight> highlights = getHighlightsAtIndex(index);

    double distanceToCenter =
        mChart.distanceToCenter(x, y) / mChart.getFactor();

    Highlight closest;
    double distance = double.infinity;

    for (int i = 0; i < highlights.length; i++) {
      Highlight high = highlights[i];

      double cdistance = (high.getY() - distanceToCenter).abs();
      if (cdistance < distance) {
        closest = high;
        distance = cdistance;
      }
    }

    return closest;
  }

  /// Returns an array of Highlight objects for the given index. The Highlight
  /// objects give information about the value at the selected index and the
  /// DataSet it belongs to. INFORMATION: This method does calculations at
  /// runtime. Do not over-use in performance critical situations.
  ///
  /// @param index
  /// @return
  List<Highlight> getHighlightsAtIndex(int index) {
    mHighlightBuffer.clear();

    double phaseX = mChart.mAnimator.getPhaseX();
    double phaseY = mChart.mAnimator.getPhaseY();
    double sliceangle = mChart.getSliceAngle();
    double factor = mChart.getFactor();

    MPPointF pOut = MPPointF.getInstance1(0, 0);
    for (int i = 0; i < mChart.getData().getDataSetCount(); i++) {
      IDataSet dataSet = mChart.getData().getDataSetByIndex(i);

      final Entry entry = dataSet.getEntryForIndex(index);

      double y = (entry.y - mChart.getYChartMin());

      Utils.getPosition(mChart.getCenterOffsets(), y * factor * phaseY,
          sliceangle * index * phaseX + mChart.getRotationAngle(), pOut);

      mHighlightBuffer.add(Highlight(
          x: index.toDouble(),
          y: entry.y,
          xPx: pOut.x,
          yPx: pOut.y,
          dataSetIndex: i,
          axis: dataSet.getAxisDependency()));
    }

    return mHighlightBuffer;
  }
}
