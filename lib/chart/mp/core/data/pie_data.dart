import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_pie_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/dart_adapter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class PieData extends ChartData<IPieDataSet> {
  PieData(IPieDataSet dataSet) : super.fromList(List()..add(dataSet));

  /// Sets the PieDataSet this data object should represent.
  ///
  /// @param dataSet
  void setDataSet(IPieDataSet dataSet) {
    mDataSets.clear();
    mDataSets.add(dataSet);
    notifyDataChanged();
  }

  /// Returns the DataSet this PieData object represents. A PieData object can
  /// only contain one DataSet.
  ///
  /// @return
  IPieDataSet getDataSet() {
    return mDataSets[0];
  }

  /// The PieData object can only have one DataSet. Use getDataSet() method instead.
  ///
  /// @param index
  /// @return
  @override
  IPieDataSet getDataSetByIndex(int index) {
    return index == 0 ? getDataSet() : null;
  }

  @override
  IPieDataSet getDataSetByLabel(String label, bool ignorecase) {
    return ignorecase
        ? DartAdapterUtils.equalsIgnoreCase(label, mDataSets[0].getLabel())
        ? mDataSets[0]
        : null
        : (label == mDataSets[0].getLabel()) ? mDataSets[0] : null;
  }

  @override
  Entry getEntryForHighlight(Highlight highlight) {
    return getDataSet().getEntryForIndex(highlight.getX().toInt());
  }

  /// Returns the sum of all values in this PieData object.
  ///
  /// @return
  double getYValueSum() {
    double sum = 0;
    for (int i = 0; i < getDataSet().getEntryCount(); i++)
      sum += getDataSet().getEntryForIndex(i).getValue();
    return sum;
  }
}