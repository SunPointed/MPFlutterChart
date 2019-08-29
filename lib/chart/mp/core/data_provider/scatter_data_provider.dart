import 'package:mp_flutter_chart/chart/mp/core/data/scatter_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bar_line_scatter_candle_bubble_data_provider.dart';

mixin ScatterDataProvider on BarLineScatterCandleBubbleDataProvider {
  ScatterData getScatterData();
}
