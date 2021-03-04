import 'package:flutter/widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mp_chart/mp/controller/controller.dart';
import 'package:optimized_gesture_detector/details.dart';
import 'package:optimized_gesture_detector/optimized_gesture_detector.dart';
import 'package:screenshot/screenshot.dart';

abstract class Chart<C extends Controller> extends StatefulWidget {
  final C controller;

  @override
  State createState() {
    return controller.createChartState();
  }

  const Chart(this.controller);
}

abstract class ChartState<T extends Chart> extends State<T> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool isCapturing = false;

  void setStateIfNotDispose() {
    if (mounted) {
      setState(() {});
    }
  }

  void updatePainter();

  void capture() async {
    if (isCapturing) return;
    isCapturing = true;

    _screenshotController.capture(pixelRatio: 3.0).then((imgFile) {
      ImageGallerySaver.saveImage(imgFile);
      isCapturing = false;
    }).catchError((error) {
      isCapturing = false;
    });
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.animator = oldWidget.controller.animator;
    widget.controller.state = this;
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.doneBeforePainterInit();
    widget.controller.initialPainter();
    updatePainter();
    return Screenshot(
        controller: _screenshotController,
        child: Container(
            child: Stack(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                children: [
              ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: double.infinity, minWidth: double.infinity),
                  child: OptimizedGestureDetector(
                      tapDown: (details) {
                        onTapDown(details);
                      },
                      singleTapUp: (details) {
                        onSingleTapUp(details);
                      },
                      doubleTapUp: (details) {
                        onDoubleTapUp(details);
                      },
                      moveStart: (details) {
                        onMoveStart(details);
                      },
                      moveUpdate: (details) {
                        onMoveUpdate(details);
                      },
                      moveEnd: (details) {
                        onMoveEnd(details);
                      },
                      scaleStart: (details) {
                        onScaleStart(details);
                      },
                      scaleUpdate: (details) {
                        onScaleUpdate(details);
                      },
                      scaleEnd: (details) {
                        onScaleEnd(details);
                      },
                      dragStart: (details) {
                        onDragStart(details);
                      },
                      dragUpdate: (details) {
                        onDragUpdate(details);
                      },
                      dragEnd: (details) {
                        onDragEnd(details);
                      },
                      needHorizontalConflictFunc:
                          widget.controller.horizontalConflictResolveFunc,
                      needVerticalConflictFunc:
                          widget.controller.verticalConflictResolveFunc,
                      child: CustomPaint(painter: widget.controller.painter))),
            ])));
  }

  @override
  void reassemble() {
    super.reassemble();
    widget.controller.animator?.reset();
    widget.controller.painter?.reassemble();
  }

  void onTapDown(TapDownDetails details);

  void onSingleTapUp(TapUpDetails details);

  void onDoubleTapUp(TapUpDetails details);

  void onMoveStart(OpsMoveStartDetails details);

  void onMoveUpdate(OpsMoveUpdateDetails details);

  void onMoveEnd(OpsMoveEndDetails details);

  void onScaleStart(OpsScaleStartDetails details);

  void onScaleUpdate(OpsScaleUpdateDetails details);

  void onScaleEnd(OpsScaleEndDetails details);

  void onDragStart(LongPressStartDetails details);

  void onDragUpdate(LongPressMoveUpdateDetails details);

  void onDragEnd(LongPressEndDetails details);
}
