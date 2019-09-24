import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/chart/pie_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/pie_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';

class PercentFormatter extends ValueFormatter {
  NumberFormat _format;
  PieChart _chart;
  bool _percentSignSeparated;

  PercentFormatter() {
    _format = NumberFormat("###,###,##0.0");
    _percentSignSeparated = true;
  }

  setPieChartPainter(PieChart chart) {
    _chart = chart;
  }

  @override
  String getFormattedValue1(double value) {
    return _format.format(value) + (_percentSignSeparated ? " %" : "%");
  }

  @override
  String getPieLabel(double value, PieEntry pieEntry) {
    if (_chart != null && _chart.painter != null && _chart.painter.isUsePercentValuesEnabled()) {
      // Converted to percent
      return getFormattedValue1(value);
    } else {
      // raw value, skip percent sign
      return _format.format(value);
    }
  }
}
