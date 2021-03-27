import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lunar_calendar/calendar/ui/day/event/EventStackedList.dart';
import 'package:lunar_calendar/global.dart';

class EventView extends StatefulWidget {
  final DateTime date;

  EventView({Key key, @required this.date}) : super(key: key) {
    debugPrint("EventView constructor: $date");
  }

  @override
  State createState() => _EventState();
}

class _EventState extends State<EventView> {
  void _onEventEdit(Event event) {
    // TODO: implement this
    debugPrint("_onEventEdit: ${event.title}");
  }

  void _onEventDelete(Event event) {
    // TODO: implement this
    debugPrint("_onEventDelete: ${event.title}");
  }

  @override
  Widget build(BuildContext context) {
    DateTime _date = widget.date;
    debugPrint("_EventState - build: $_date");

    return new FutureBuilder<List<Event>>(
      future: pluginWrapper.getEvents(
        start: _date,
        end: _date.add(const Duration(days: 1)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return Container();

        debugPrint("List size: ${snapshot.data?.length}");

        var events = snapshot.data;
        events ??= [];

        return Visibility(
          visible: events.isNotEmpty,
          child: Expanded(
            child: Container(
              margin: EdgeInsets.all(5),
              child: EventStackedList(
                events: events,
                eventEdit: _onEventEdit,
                eventDelete: _onEventDelete,
              ),
            ),
          ),
        );
      },
    );
  }
}
