import 'dart:math';
import 'dart:ui';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

///
/// Refer from: https://stackoverflow.com/a/57513788/4234055
///

class EventStackedList extends StatelessWidget {
  final List<Color> _colors = [
    Colors.white70,
    Colors.greenAccent.shade100,
  ];
  static const _minHeight = 30.0;
  static const _maxHeight = 120.0;

  final List<Event> events;
  final ValueChanged<Event> eventEdit;
  final ValueChanged<Event> eventDelete;

  EventStackedList({
    Key key,
    this.events,
    this.eventEdit,
    this.eventDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return CustomScrollView(
      slivers: List.generate(events.length, (index) {
        return _StackedListChild(
          minHeight: _minHeight,
          maxHeight: (index == events.length - 1) ? screenHeight : _maxHeight,
          pinned: true,
          child: Container(
            color: (index == 0) ? Colors.transparent : _colors[index % 2],
            child: Container(
              decoration: BoxDecoration(
                color: (index % 2 == 0 ? _colors[1] : _colors[0]),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 10, top: 5, right: 5),
                child: _EventDetail(
                  event: events[index],
                  onEdit: () {
                    eventEdit?.call(events[index]);
                  },
                  onDelete: () {
                    eventDelete?.call(events[index]);
                  },
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EventDetail extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventDetail({
    Key key,
    @required this.event,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            "${event.title}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          child: Icon(Icons.edit, size: 18),
          onTap: onEdit,
        ),
        GestureDetector(
          child: Icon(Icons.delete_forever_sharp, size: 19),
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _StackedListChild extends StatelessWidget {
  final double minHeight;
  final double maxHeight;
  final bool pinned;
  final bool floating;
  final Widget child;

  SliverPersistentHeaderDelegate get _delegate => _StackedListDelegate(
        minHeight: minHeight,
        maxHeight: maxHeight,
        child: child,
      );

  const _StackedListChild({
    Key key,
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
    this.pinned = false,
    this.floating = false,
  })  : assert(child != null),
        assert(minHeight != null),
        assert(maxHeight != null),
        assert(pinned != null),
        assert(floating != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        key: key,
        pinned: pinned,
        floating: floating,
        delegate: _delegate,
      );
}

class _StackedListDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StackedListDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(_StackedListDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
