import 'package:intl/intl.dart' show NumberFormat;
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

abstract class ValueFormatter {
  String getFormattedValue2(double value, AxisBase axis) {
    return getFormattedValue1(value);
  }

  String getFormattedValue3(double value, Entry entry, int dataSetIndex,
      ViewPortHandler viewPortHandler) {
    return getFormattedValue1(value);
  }

  String getFormattedValue1(double value) {
    return value.toString();
  }

  String getAxisLabel(double value, AxisBase axis) {
    return getFormattedValue1(value);
  }

  String getBarLabel(BarEntry barEntry) {
    return getFormattedValue1(barEntry.y);
  }

  String getBarStackedLabel(double value, BarEntry stackedEntry) {
    return getFormattedValue1(value);
  }

  String getPointLabel(Entry entry) {
    return getFormattedValue1(entry.y);
  }

//  String getPieLabel(double value, PieEntry pieEntry) {
//    return getFormattedValue(value);
//  }
//
//  String getRadarLabel(RadarEntry radarEntry) {
//    return getFormattedValue(radarEntry.getY());
//  }
//
//  String getBubbleLabel(BubbleEntry bubbleEntry) {
//    return getFormattedValue(bubbleEntry.getSize());
//  }
//
//  String getCandleLabel(CandleEntry candleEntry) {
//    return getFormattedValue(candleEntry.getHigh());
//  }
}

class DefaultAxisValueFormatter extends ValueFormatter {
  /**
   * decimalformat for formatting
   */
  NumberFormat mFormat;

  /**
   * the number of decimal digits this formatter uses
   */
  int digits;

  /**
   * Constructor that specifies to how many digits the value should be
   * formatted.
   *
   * @param digits
   */
  DefaultAxisValueFormatter(int digits) {
    this.digits = digits;

    StringBuffer b = new StringBuffer();
    for (int i = 0; i < digits; i++) {
      if (i == 0) b.write(".");
      b.write("0");
    }

    mFormat = new NumberFormat("###,###,###,##0" + b.toString());
  }

  @override
  String getFormattedValue1(double value) {
    // avoid memory allocations here (for performance)
    return mFormat.format(value);
  }

  /**
   * Returns the number of decimal digits this formatter uses or -1, if unspecified.
   *
   * @return
   */
  int getDecimalDigits() {
    return digits;
  }
}

class DefaultValueFormatter extends ValueFormatter {
  /**
   * DecimalFormat for formatting
   */
  NumberFormat mFormat;

  int mDecimalDigits;

  /**
   * Constructor that specifies to how many digits the value should be
   * formatted.
   *
   * @param digits
   */
  DefaultValueFormatter(int digits) {
    setup(digits);
  }

  /**
   * Sets up the formatter with a given number of decimal digits.
   *
   * @param digits
   */
  void setup(int digits) {
    this.mDecimalDigits = digits;

    if (digits < 1) {
      digits = 1;
    }

    StringBuffer b = new StringBuffer();
    b.write(".");
    for (int i = 0; i < digits; i++) {
      b.write("0");
    }
    mFormat = new NumberFormat("###,###,###,##0" + b.toString());
  }

  @override
  String getFormattedValue1(double value) {
    // put more logic here ...
    // avoid memory allocations here (for performance reasons)

    return mFormat.format(value);
  }

  @override
  String toString() {
    return mFormat.toString();
  }

  /**
   * Returns the number of decimal digits this formatter uses.
   *
   * @return
   */
  int getDecimalDigits() {
    return mDecimalDigits;
  }
}

class DefaultFillFormatter implements IFillFormatter {
  @override
  double getFillLinePosition(
      ILineDataSet dataSet, LineDataProvider dataProvider) {
    double fillMin = 0;
    double chartMaxY = dataProvider.getYChartMax();
    double chartMinY = dataProvider.getYChartMin();

    LineData data = dataProvider.getLineData();

    if (dataSet.getYMax() > 0 && dataSet.getYMin() < 0) {
      fillMin = 0;
    } else {
      double max, min;

      if (data.getYMax1() > 0)
        max = 0;
      else
        max = chartMaxY;
      if (data.getYMin1() < 0)
        min = 0;
      else
        min = chartMinY;

      fillMin = dataSet.getYMin() >= 0 ? min : max;
    }
    return fillMin;
  }
}
