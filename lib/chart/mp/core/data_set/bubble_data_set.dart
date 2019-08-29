import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bubble_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class BubbleDataSet extends BarLineScatterCandleBubbleDataSet<BubbleEntry>
    implements IBubbleDataSet {
  double mMaxSize = 0.0;
  bool mNormalizeSize = true;

  double mHighlightCircleWidth = 2.5;

  BubbleDataSet(List<BubbleEntry> yVals, String label) : super(yVals, label);

  @override
  void setHighlightCircleWidth(double width) {
    mHighlightCircleWidth = Utils.convertDpToPixel(width);
  }

  @override
  double getHighlightCircleWidth() {
    return mHighlightCircleWidth;
  }

  @override
  void calcMinMax1(BubbleEntry e) {
    super.calcMinMax1(e);

    final double size = e.getSize();

    if (size > mMaxSize) {
      mMaxSize = size;
    }
  }

  @override
  DataSet<BubbleEntry> copy1() {
    List<BubbleEntry> entries = List<BubbleEntry>();
    for (int i = 0; i < mValues.length; i++) {
      entries.add(mValues[i].copy());
    }
    BubbleDataSet copied = BubbleDataSet(entries, getLabel());
    copy(copied);
    return copied;
  }

  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);
    if (baseDataSet is BubbleDataSet) {
      var bubbleDataSet = baseDataSet;
      bubbleDataSet.mHighlightCircleWidth = mHighlightCircleWidth;
      bubbleDataSet.mNormalizeSize = mNormalizeSize;
    }
  }

  @override
  double getMaxSize() {
    return mMaxSize;
  }

  @override
  bool isNormalizeSizeEnabled() {
    return mNormalizeSize;
  }

  void setNormalizeSizeEnabled(bool normalizeSize) {
    mNormalizeSize = normalizeSize;
  }
}
