import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';

mixin ILineScatterCandleRadarDataSet<T extends Entry>
    on IBarLineScatterCandleBubbleDataSet<T> {
  /// Returns true if vertical highlight indicator lines are enabled (drawn)
  /// @return
  bool isVerticalHighlightIndicatorEnabled();

  /// Returns true if vertical highlight indicator lines are enabled (drawn)
  /// @return
  bool isHorizontalHighlightIndicatorEnabled();

  /// Returns the line-width in which highlight lines are to be drawn.
  /// @return
  double getHighlightLineWidth();

/// Returns the DashPathEffect that is used for highlighting.
/// @return
//  DashPathEffect getDashPathEffectHighlight();
}
