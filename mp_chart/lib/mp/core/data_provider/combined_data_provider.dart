import 'package:mp_chart/mp/core/data/combined_data.dart';
import 'package:mp_chart/mp/core/data_provider/bar_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/bubble_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/candle_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/line_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/scatter_data_provider.dart';

mixin CombinedDataProvider
    on
        LineDataProvider,
        BarDataProvider,
        BubbleDataProvider,
        CandleDataProvider,
        ScatterDataProvider {
  CombinedData getCombinedData();
}
