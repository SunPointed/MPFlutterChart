import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';

/**
 * Listener for callbacks when doing gestures on the chart.
 *
 * @author Philipp Jahoda
 */
mixin OnChartGestureListener {
  /**
   * Callbacks when a touch-gesture has started on the chart (ACTION_DOWN)
   *
   * @param me
   * @param lastPerformedGesture
   */
//  void onChartGestureStart(
//      MotionEvent me, ChartTouchListener.ChartGesture lastPerformedGesture);
//
//  /**
//   * Callbacks when a touch-gesture has ended on the chart (ACTION_UP, ACTION_CANCEL)
//   *
//   * @param me
//   * @param lastPerformedGesture
//   */
//  void onChartGestureEnd(
//      MotionEvent me, ChartTouchListener.ChartGesture lastPerformedGesture);

  /**
   * Callbacks when the chart is longpressed.
   *
   * @param me
   */
//  void onChartLongPressed(MotionEvent me);

  /**
   * Callbacks when the chart is double-tapped.
   *
   * @param me
   */
  void onChartDoubleTapped(double positionX, double positionY);

  /**
   * Callbacks when the chart is single-tapped.
   *
   * @param me
   */
  void onChartSingleTapped(double positionX, double positionY);

  /**
   * Callbacks then a fling gesture is made on the chart.
   *
   * @param me1
   * @param me2
   * @param velocityX
   * @param velocityY
   */
//  void onChartFling(
//      MotionEvent me1, MotionEvent me2, double velocityX, double velocityY);

  /**
   * Callbacks when the chart is scaled / zoomed via pinch zoom gesture.
   *
   * @param me
   * @param scaleX scalefactor on the x-axis
   * @param scaleY scalefactor on the y-axis
   */
  void onChartScale(
      double positionX, double positionY, double scaleX, double scaleY);

  /**
   * Callbacks when the chart is moved / translated via drag gesture.
   *
   * @param me
   * @param dX translation distance on the x-axis
   * @param dY translation distance on the y-axis
   */
  void onChartTranslate(
      double positionX, double positionY, double dX, double dY);
}

/**
 * Listener for callbacks when selecting values inside the chart by
 * touch-gesture.
 *
 * @author Philipp Jahoda
 */
mixin OnChartValueSelectedListener {
  /**
   * Called when a value has been selected inside the chart.
   *
   * @param e The selected Entry
   * @param h The corresponding highlight object that contains information
   *          about the highlighted position such as dataSetIndex, ...
   */
  void onValueSelected(Entry e, Highlight h);

  /**
   * Called when nothing has been selected or an "un-select" has been made.
   */
  void onNothingSelected();
}

mixin AnimatorUpdateListener {
  void onAnimationUpdate(double x, double y);
}
