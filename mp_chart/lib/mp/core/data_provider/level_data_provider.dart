import 'package:mp_chart/mp/core/axis/y_axis.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';

import 'bar_line_scatter_candle_bubble_data_provider.dart';
import 'line_data_provider.dart';

mixin LevelDataProvider implements BarLineScatterCandleBubbleDataProvider {
  LineData getLevelData();

  YAxis getAxis(AxisDependency dependency);
}
