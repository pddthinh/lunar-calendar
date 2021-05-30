import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lunar_calendar/calendar/CalendarPluginWrapper.dart';
import 'package:lunar_calendar/calendar/ui/day/event/EventDetail.dart';
import 'package:lunar_calendar/calendar/ui/day/event/EventStackedList.dart';
import 'package:lunar_calendar/global.dart';

class EventList extends StatefulWidget {
  final DateTime date;

  ///
  /// Notify the parent if there is any update
  final ValueChanged<bool> onUpdated;

  EventList({
    Key key,
    @required this.date,
    this.onUpdated,
  }) : super(key: key);

  @override
  State createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  void _refresh() {
    debugPrint("$this --> refreshing ...");

    setState(() => widget.onUpdated?.call(true));
  }

  void _onEventEdit(BuildContext context, Event event) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (context) => EventDetail(event: event)),
    )
        .then(
      (value) {
        if (value == null || !value) return;

        _refresh();
      },
    );
  }

  void _deleteEvent(
    BuildContext context,
    Event event,
    bool removeRecurrence,
  ) async {
    bool deleted;

    // do {
    //   // Single event or remove all?
    //   if (event.recurrenceRule == null || removeRecurrence) {
    //     deleted = await pluginWrapper.deleteEvent(event);
    //     break;
    //   }
    //
    //   // Just remove this event instance only
    //   deleted = await pluginWrapper.deleteRecurrenceEvents(event, true);
    // } while (false);

    deleted = await pluginWrapper.deleteEvent(event);

    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed deleting the event!"),
        ),
      );
      return;
    }

    _refresh();
  }

  void _onEventDelete(BuildContext context, Event event) async {
    showDialog(
      context: context,
      builder: (context) {
        var _removeRecurrence = false;

        return AlertDialog(
          title: const Text("Remove Event"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEvent(context, event, _removeRecurrence);
              },
            ),
          ],
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Are you sure you want to remove this event?"),
                  Visibility(
                    visible: false,
                    //TODO: Implement this to support delete single event in the recurrence!
                    child: CheckboxListTile(
                      title: const Text("Include all recurrence events"),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _removeRecurrence,
                      onChanged: (value) =>
                          setState(() => _removeRecurrence = value),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime _date = widget.date;

    return new FutureBuilder<List<Event>>(
      future: pluginWrapper.getEvents(
        start: _date,
        end: _date.add(const Duration(days: 1)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return Container();

        var events = snapshot.data;
        events ??= [];

        // debugPrint("$this --> Event list: $events");
        events.forEach((element) => debugPrint("Event: ${element.json}"));

        return Visibility(
          visible: events.isNotEmpty,
          child: Expanded(
            child: Container(
              margin: EdgeInsets.all(5),
              child: EventStackedList(
                events: events,
                eventEdit: (event) => _onEventEdit(context, event),
                eventDelete: (event) => _onEventDelete(context, event),
              ),
            ),
          ),
        );
      },
    );
  }
}
