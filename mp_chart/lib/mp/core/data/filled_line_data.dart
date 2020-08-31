import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/filled_line_data_set.dart';

import 'bar_line_scatter_candle_bubble_data.dart';

class FilledLineData extends BarLineScatterCandleBubbleData<FilledLineDataSet> {
  FilledLineData() : super();

  FilledLineData.fromList(List<FilledLineDataSet> sets) : super.fromList(sets);
}
