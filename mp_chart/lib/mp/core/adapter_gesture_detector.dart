import 'package:flutter/widgets.dart';

class AdapterGestureDetector extends StatelessWidget {
  final AdapterOnTapDown adapterOnTapDown;
  final AdapterOnTapUp adapterOnTapUp;
  final AdapterOnDoubleTap adapterOnDoubleTap;
  final AdapterOnScaleStart adapterOnScaleStart;
  final AdapterOnScaleUpdate adapterOnScaleUpdate;
  final AdapterOnScaleEnd adapterOnScaleEnd;
  final Widget child;

  const AdapterGestureDetector({
    Key key,
    this.child,
    this.adapterOnTapDown,
    this.adapterOnTapUp,
    this.adapterOnDoubleTap,
    this.adapterOnScaleStart,
    this.adapterOnScaleUpdate,
    this.adapterOnScaleEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (detail) {
          if (adapterOnTapDown != null) {
            adapterOnTapDown(detail, context);
          }
        },
        onTapUp: (detail) {
          if (adapterOnTapUp != null) {
            adapterOnTapUp(detail, context);
          }
        },
        onDoubleTap: () {
          if (adapterOnDoubleTap != null) {
            adapterOnDoubleTap(context);
          }
        },
        onScaleStart: (detail) {
          if (adapterOnScaleStart != null) {
            adapterOnScaleStart(detail, context);
          }
        },
        onScaleUpdate: (detail) {
          if (adapterOnScaleUpdate != null) {
            adapterOnScaleUpdate(detail, context);
          }
        },
        onScaleEnd: (detail) {
          if (adapterOnScaleEnd != null) {
            adapterOnScaleEnd(detail, context);
          }
        },
        child: child);
  }
}

typedef AdapterOnTapDown = void Function(
    TapDownDetails details, BuildContext context);

typedef AdapterOnTapUp = void Function(
    TapUpDetails details, BuildContext context);

typedef AdapterOnDoubleTap = void Function(BuildContext context);

typedef AdapterOnScaleStart = void Function(
    ScaleStartDetails details, BuildContext context);

typedef AdapterOnScaleUpdate = void Function(
    ScaleUpdateDetails details, BuildContext context);

typedef AdapterOnScaleEnd = void Function(
    ScaleEndDetails details, BuildContext context);
