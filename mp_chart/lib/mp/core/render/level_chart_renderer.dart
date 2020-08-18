import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_provider/level_data_provider.dart';

import 'package:mp_chart/mp/core/data_provider/line_data_provider.dart';

import 'package:mp_chart/mp/core/view_port.dart';

import 'line_chart_renderer.dart';

class LevelChartRenderer extends LineChartRenderer {
  LevelChartRenderer(LineDataProvider chart, Animator animator, ViewPortHandler viewPortHandler) : super(chart, animator, viewPortHandler);

  @override LineData getData() {
    return (provider as LevelDataProvider).getLevelData();
  }
}