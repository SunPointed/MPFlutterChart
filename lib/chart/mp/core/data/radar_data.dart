import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';

class RadarData extends ChartData<IRadarDataSet> {
  List<String> mLabels;

  RadarData() : super();

  RadarData.fromList(List<IRadarDataSet> dataSets) : super.fromList(dataSets);

  /// Sets the labels that should be drawn around the RadarChart at the end of each web line.
  ///
  /// @param labels
  void setLabels(List<String> labels) {
    this.mLabels = labels;
  }

  List<String> getLabels() {
    return mLabels;
  }

  @override
  Entry getEntryForHighlight(Highlight highlight) {
    return getDataSetByIndex(highlight.getDataSetIndex())
        .getEntryForIndex(highlight.getX().toInt());
  }
}
