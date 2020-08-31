import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';

class FilledLineDataSet extends LineDataSet {
  List<Entry> lowLevelEntries;
  List<Entry> highLevelEntries;
  FilledLineDataSet(this.highLevelEntries, this.lowLevelEntries, String label) : super(highLevelEntries, label);

}