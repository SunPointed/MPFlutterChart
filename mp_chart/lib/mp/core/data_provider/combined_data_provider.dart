import 'package:mp_chart/mp/core/data/combined_data.dart';
import 'package:mp_chart/mp/core/data_provider/bar_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/bubble_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/candle_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/filled_line_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/level_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/line_data_provider.dart';
import 'package:mp_chart/mp/core/data_provider/scatter_data_provider.dart';

mixin CombinedDataProvider
    implements
        LevelDataProvider,
        LineDataProvider,
        BarDataProvider,
        BubbleDataProvider,
        CandleDataProvider,
        ScatterDataProvider,
        FilledLineDataProvider {
  CombinedData getCombinedData();
}
