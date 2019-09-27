import 'package:mp_chart/mp/chart/bar_line_scatter_candle_bubble_chart.dart';
import 'package:mp_chart/mp/chart/chart.dart';
import 'package:mp_chart/mp/chart/radar_chart.dart';
import 'package:mp_chart/mp/core/axis/x_axis.dart';
import 'package:mp_chart/mp/core/axis/y_axis.dart';
import 'package:mp_chart/mp/core/legend/legend.dart';
import 'package:mp_chart/mp/core/render/data_renderer.dart';

typedef XAxisSettingFunction = void Function(XAxis xAxis, Chart chart);
typedef LegendSettingFunction = void Function(Legend legend, Chart chart);
typedef YAxisSettingFunction = void Function(YAxis yAxis, RadarChart chart);
typedef AxisLeftSettingFunction = void Function(
    YAxis axisLeft, BarLineScatterCandleBubbleChart chart);
typedef AxisRightSettingFunction = void Function(
    YAxis axisRight, BarLineScatterCandleBubbleChart chart);
typedef DataRendererSettingFunction = void Function(
    DataRenderer renderer);
