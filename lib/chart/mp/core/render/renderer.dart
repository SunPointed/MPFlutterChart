import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

abstract class Renderer {
  /**
   * the component that handles the drawing area of the chart and it's offsets
   */
  ViewPortHandler mViewPortHandler;

  Renderer(this.mViewPortHandler);
}