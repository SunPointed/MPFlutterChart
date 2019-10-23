import 'package:flutter/widgets.dart';

class AdapterListener extends StatelessWidget {
  final Widget child;
  final AdapterOnPointerDown adapterOnPointerDown;
  final AdapterOnPointerMove adapterOnPointerMove;
  final AdapterOnPointerUp adapterOnPointerUp;

  const AdapterListener(
      {Key key,
      this.child,
      this.adapterOnPointerDown,
      this.adapterOnPointerMove,
      this.adapterOnPointerUp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (e) {
          if(adapterOnPointerDown != null){
            adapterOnPointerDown(e, context);
          }
        },
        onPointerMove: (e) {
          if(adapterOnPointerMove != null){
            adapterOnPointerMove(e, context);
          }
        },
        onPointerUp: (e) {
          if(adapterOnPointerUp != null){
            adapterOnPointerUp(e, context);
          }
        },
        child: child);
  }
}

typedef AdapterOnPointerDown = void Function(
    PointerDownEvent event, BuildContext context);

typedef AdapterOnPointerMove = void Function(
    PointerMoveEvent event, BuildContext context);

typedef AdapterOnPointerUp = void Function(
    PointerUpEvent event, BuildContext context);
