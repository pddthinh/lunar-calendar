import 'package:flutter/cupertino.dart';

class SwipeDetector extends GestureDetector {
  SwipeDetector(
      {Key key,
      @required Widget child,
      void Function() onNext,
      void Function() onPrevious})
      : super(
            key: key,
            child: child,
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (dragEvent) {
              if (dragEvent.primaryVelocity == 0) return;

              if (dragEvent.primaryVelocity < 0) {
                if (onNext != null) onNext();
              } else {
                if (onPrevious != null) onPrevious();
              }
            });
}
