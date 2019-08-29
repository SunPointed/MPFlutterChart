import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bubble_entry.dart';

mixin IBubbleDataSet on IBarLineScatterCandleBubbleDataSet<BubbleEntry> {
  /**
   * Sets the width of the circle that surrounds the bubble when highlighted,
   * in dp.
   *
   * @param width
   */
  void setHighlightCircleWidth(double width);

  double getMaxSize();

  bool isNormalizeSizeEnabled();

  /**
   * Returns the width of the highlight-circle that surrounds the bubble
   * @return
   */
  double getHighlightCircleWidth();
}
