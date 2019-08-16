import 'dart:math';

import 'package:intl/intl.dart' show NumberFormat;
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_line_chart_painter.dart';

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

    StringBuffer b = StringBuffer();
    for (int i = 0; i < digits; i++) {
      if (i == 0) b.write(".");
      b.write("0");
    }

    mFormat = NumberFormat("###,###,###,##0" + b.toString());
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

    StringBuffer b = StringBuffer();
    b.write(".");
    for (int i = 0; i < digits; i++) {
      b.write("0");
    }
    mFormat = NumberFormat("###,###,###,##0" + b.toString());
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

class MyValueFormatter extends ValueFormatter {
  NumberFormat mFormat;
  String suffix;

  MyValueFormatter(String suffix) {
    mFormat = NumberFormat("###,###,###,##0.0");
    this.suffix = suffix;
  }

  @override
  String getFormattedValue1(double value) {
    return mFormat.format(value) + suffix;
  }

  @override
  String getAxisLabel(double value, AxisBase axis) {
    if (axis is XAxis) {
      return mFormat.format(value);
    } else if (value > 0) {
      return mFormat.format(value) + suffix;
    } else {
      return mFormat.format(value);
    }
  }
}

class DayAxisValueFormatter extends ValueFormatter {
  final List<String> mMonths = List()
    ..add("Jan")
    ..add("Feb")
    ..add("Mar")
    ..add("Apr")
    ..add("May")
    ..add("Jun")
    ..add("Jul")
    ..add("Aug")
    ..add("Sep")
    ..add("Oct")
    ..add("Nov")
    ..add("Dec");

  BarLineChartBasePainter chart;

  DayAxisValueFormatter(BarLineChartBasePainter chart) {
    this.chart = chart;
  }

  @override
  String getFormattedValue1(double value) {
    int days = value.toInt();

    int year = determineYear(days);

    int month = determineMonth(days);
    String monthName = mMonths[month % mMonths.length];
    String yearName = year.toString();

    if (chart.getVisibleXRange() > 30 * 6) {
      return monthName + " " + yearName;
    } else {
      int dayOfMonth = determineDayOfMonth(days, month + 12 * (year - 2016));

      String appendix = "th";

      switch (dayOfMonth) {
        case 1:
          appendix = "st";
          break;
        case 2:
          appendix = "nd";
          break;
        case 3:
          appendix = "rd";
          break;
        case 21:
          appendix = "st";
          break;
        case 22:
          appendix = "nd";
          break;
        case 23:
          appendix = "rd";
          break;
        case 31:
          appendix = "st";
          break;
      }

      return dayOfMonth == 0 ? "" : "$dayOfMonth$appendix $monthName";
    }
  }

  int getDaysForMonth(int month, int year) {
    // month is 0-based

    if (month == 1) {
      bool is29Feb = false;

      if (year < 1582)
        is29Feb = (year < 1 ? year + 1 : year) % 4 == 0;
      else if (year > 1582)
        is29Feb = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

      return is29Feb ? 29 : 28;
    }

    if (month == 3 || month == 5 || month == 8 || month == 10)
      return 30;
    else
      return 31;
  }

  int determineMonth(int dayOfYear) {
    int month = -1;
    int days = 0;

    while (days < dayOfYear) {
      month = month + 1;

      if (month >= 12) month = 0;

      int year = determineYear(days);
      days += getDaysForMonth(month, year);
    }

    return max(month, 0);
  }

  int determineDayOfMonth(int days, int month) {
    int count = 0;
    int daysForMonths = 0;

    while (count < month) {
      int year = determineYear(daysForMonths);
      daysForMonths += getDaysForMonth(count % 12, year);
      count++;
    }

    return days - daysForMonths;
  }

  int determineYear(int days) {
    if (days <= 366)
      return 2016;
    else if (days <= 730)
      return 2017;
    else if (days <= 1094)
      return 2018;
    else if (days <= 1458)
      return 2019;
    else
      return 2020;
  }
}
