import 'package:mp_flutter_chart/chart/mp/core/axis/axis_base.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class XAxis extends AxisBase {
  /// width of the x-axis labels in pixels - this is automatically
  /// calculated by the computeSize() methods in the renderers
  int mLabelWidth = 1;

  /// height of the x-axis labels in pixels - this is automatically
  /// calculated by the computeSize() methods in the renderers
  int mLabelHeight = 1;

  /// width of the (rotated) x-axis labels in pixels - this is automatically
  /// calculated by the computeSize() methods in the renderers
  int mLabelRotatedWidth = 1;

  /// height of the (rotated) x-axis labels in pixels - this is automatically
  /// calculated by the computeSize() methods in the renderers
  int mLabelRotatedHeight = 1;

  /// This is the angle for drawing the X axis labels (in degrees)
  double mLabelRotationAngle = 0;

  /// if set to true, the chart will avoid that the first and last label entry
  /// in the chart "clip" off the edge of the chart
  bool mAvoidFirstLastClipping = false;

  /// the position of the x-labels relative to the chart
  XAxisPosition mPosition = XAxisPosition.TOP;

  XAxis() : super() {
    mYOffset = Utils.convertDpToPixel(4); // -3
  }

  /// returns the position of the x-labels
  XAxisPosition getPosition() {
    return mPosition;
  }

  /// sets the position of the x-labels
  ///
  /// @param pos
  void setPosition(XAxisPosition pos) {
    mPosition = pos;
  }

  /// returns the angle for drawing the X axis labels (in degrees)
  double getLabelRotationAngle() {
    return mLabelRotationAngle;
  }

  /// sets the angle for drawing the X axis labels (in degrees)
  ///
  /// @param angle the angle in degrees
  void setLabelRotationAngle(double angle) {
    mLabelRotationAngle = angle;
  }

  /// if set to true, the chart will avoid that the first and last label entry
  /// in the chart "clip" off the edge of the chart or the screen
  ///
  /// @param enabled
  void setAvoidFirstLastClipping(bool enabled) {
    mAvoidFirstLastClipping = enabled;
  }

  /// returns true if avoid-first-lastclipping is enabled, false if not
  ///
  /// @return
  bool isAvoidFirstLastClippingEnabled() {
    return mAvoidFirstLastClipping;
  }
}
