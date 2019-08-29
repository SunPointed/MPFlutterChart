import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/pie_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';

class PercentFormatter extends ValueFormatter {
  NumberFormat mFormat;
  PieChartPainter pieChart;
  bool percentSignSeparated;

  PercentFormatter() {
    mFormat = NumberFormat("###,###,##0.0");
    percentSignSeparated = true;
  }

  setPieChartPainter(PieChartPainter painter) {
    pieChart = painter;
  }

  @override
  String getFormattedValue1(double value) {
    return mFormat.format(value) + (percentSignSeparated ? " %" : "%");
  }

  @override
  String getPieLabel(double value, PieEntry pieEntry) {
    if (pieChart != null && pieChart.isUsePercentValuesEnabled()) {
      // Converted to percent
      return getFormattedValue1(value);
    } else {
      // raw value, skip percent sign
      return mFormat.format(value);
    }
  }
}
