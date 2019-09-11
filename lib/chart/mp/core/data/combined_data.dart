import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_line_scatter_candle_bubble_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bubble_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/candle_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/scatter_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';

class CombinedData extends BarLineScatterCandleBubbleData<
    IBarLineScatterCandleBubbleDataSet<Entry>> {
  LineData mLineData;
  BarData mBarData;
  ScatterData mScatterData;
  CandleData mCandleData;
  BubbleData mBubbleData;

  CombinedData() : super();

  void setData1(LineData data) {
    mLineData = data;
    notifyDataChanged();
  }

  void setData2(BarData data) {
    mBarData = data;
    notifyDataChanged();
  }

  void setData3(ScatterData data) {
    mScatterData = data;
    notifyDataChanged();
  }

  void setData4(CandleData data) {
    mCandleData = data;
    notifyDataChanged();
  }

  void setData5(BubbleData data) {
    mBubbleData = data;
    notifyDataChanged();
  }

  @override
  void calcMinMax1() {
    if (mDataSets == null) {
      mDataSets = List();
    }
    mDataSets.clear();

    mYMax = -double.maxFinite;
    mYMin = double.maxFinite;
    mXMax = -double.maxFinite;
    mXMin = double.maxFinite;

    mLeftAxisMax = -double.maxFinite;
    mLeftAxisMin = double.maxFinite;
    mRightAxisMax = -double.maxFinite;
    mRightAxisMin = double.maxFinite;

    List<BarLineScatterCandleBubbleData> allData = getAllData();

    for (ChartData data in allData) {
      data.calcMinMax1();

      List<IBarLineScatterCandleBubbleDataSet<Entry>> sets = data.getDataSets();
      mDataSets.addAll(sets);

      if (data.getYMax1() > mYMax) mYMax = data.getYMax1();

      if (data.getYMin1() < mYMin) mYMin = data.getYMin1();

      if (data.getXMax() > mXMax) mXMax = data.getXMax();

      if (data.getXMin() < mXMin) mXMin = data.getXMin();

      if (data.mLeftAxisMax > mLeftAxisMax) mLeftAxisMax = data.mLeftAxisMax;

      if (data.mLeftAxisMin < mLeftAxisMin) mLeftAxisMin = data.mLeftAxisMin;

      if (data.mRightAxisMax > mRightAxisMax)
        mRightAxisMax = data.mRightAxisMax;

      if (data.mRightAxisMin < mRightAxisMin)
        mRightAxisMin = data.mRightAxisMin;
    }
  }

  BubbleData getBubbleData() {
    return mBubbleData;
  }

  LineData getLineData() {
    return mLineData;
  }

  BarData getBarData() {
    return mBarData;
  }

  ScatterData getScatterData() {
    return mScatterData;
  }

  CandleData getCandleData() {
    return mCandleData;
  }

  /// Returns all data objects in row: line-bar-scatter-candle-bubble if not null.
  ///
  /// @return
  List<BarLineScatterCandleBubbleData> getAllData() {
    List<BarLineScatterCandleBubbleData> data =
        List<BarLineScatterCandleBubbleData>();
    if (mLineData != null) data.add(mLineData);
    if (mBarData != null) data.add(mBarData);
    if (mScatterData != null) data.add(mScatterData);
    if (mCandleData != null) data.add(mCandleData);
    if (mBubbleData != null) data.add(mBubbleData);

    return data;
  }

  BarLineScatterCandleBubbleData getDataByIndex(int index) {
    return getAllData()[index];
  }

  @override
  void notifyDataChanged() {
    if (mLineData != null) mLineData.notifyDataChanged();
    if (mBarData != null) mBarData.notifyDataChanged();
    if (mCandleData != null) mCandleData.notifyDataChanged();
    if (mScatterData != null) mScatterData.notifyDataChanged();
    if (mBubbleData != null) mBubbleData.notifyDataChanged();

    calcMinMax1(); // recalculate everything
  }

  /// Get the Entry for a corresponding highlight object
  ///
  /// @param highlight
  /// @return the entry that is highlighted
  @override
  Entry getEntryForHighlight(Highlight highlight) {
    if (highlight.getDataIndex() >= getAllData().length ||
        highlight.getDataIndex() < 0) return null;

    ChartData data = getDataByIndex(highlight.getDataIndex());

    if (highlight.getDataSetIndex() >= data.getDataSetCount()) return null;

    // The value of the highlighted entry could be NaN -
    //   if we are not interested in highlighting a specific value.

    List<Entry> entries = data
        .getDataSetByIndex(highlight.getDataSetIndex())
        .getEntriesForXValue(highlight.getX());
    for (Entry entry in entries)
      if (entry.y == highlight.getY() || highlight.getY().isNaN) return entry;

    return null;
  }

  /// Get dataset for highlight
  ///
  /// @param highlight current highlight
  /// @return dataset related to highlight
  IBarLineScatterCandleBubbleDataSet<Entry> getDataSetByHighlight(
      Highlight highlight) {
    if (highlight.getDataIndex() >= getAllData().length ||
        highlight.getDataIndex() < 0) return null;

    BarLineScatterCandleBubbleData data =
        getDataByIndex(highlight.getDataIndex());

    if (highlight.getDataSetIndex() >= data.getDataSetCount()) return null;

    return data.getDataSets()[highlight.getDataSetIndex()];
  }

  int getDataIndex(ChartData data) {
    return getAllData().indexOf(data);
  }

  @override
  bool removeDataSet1(IBarLineScatterCandleBubbleDataSet<Entry> d) {
    List<BarLineScatterCandleBubbleData> datas = getAllData();
    bool success = false;
    for (ChartData data in datas) {
      success = data.removeDataSet1(d);
      if (success) {
        break;
      }
    }
    return success;
  }
}
