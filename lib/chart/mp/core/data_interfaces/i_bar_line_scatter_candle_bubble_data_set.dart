import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';

mixin IBarLineScatterCandleBubbleDataSet<T extends Entry> on IDataSet<T> {
  /// Returns the color that is used for drawing the highlight indicators.
  ///
  /// @return
  Color getHighLightColor();
}