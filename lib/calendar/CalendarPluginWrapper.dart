import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:lunar_calendar/calendar/LunarEventManager.dart';

class CalendarPluginWrapper {
  static const CALENDAR_NAME = "Lunar-Calendar";

  DeviceCalendarPlugin _calPlugin = DeviceCalendarPlugin();
  Calendar _calendar;
  bool _init = false;

  Future<void> initCalendar() async {
    try {
      var permissionGranted = await _calPlugin.hasPermissions();
      if (permissionGranted.isSuccess && !permissionGranted.data) {
        permissionGranted = await _calPlugin.requestPermissions();
        if (!permissionGranted.isSuccess || !permissionGranted.data) {
          debugPrint("Failed to request permission!");
          return;
        }
      }

      // Retrieve the existing calendar if any
      await _getCalendar();
      if (_calendar == null) {
        // Create new calendar
        Result<String> createResult =
            await _calPlugin.createCalendar(CALENDAR_NAME);
        if (!createResult.isSuccess)
          throw Exception("Failed to create $CALENDAR_NAME");

        await _getCalendar();
      }

      if (_calendar == null)
        throw Exception("Failed to retrieve the calendar name: $CALENDAR_NAME");

      _init = true;
    } catch (ex) {
      debugPrint("Error: $ex");
    }
  }

  Future<void> _getCalendar() async {
    Result<List<Calendar>> calResult = await _calPlugin.retrieveCalendars();
    calResult.data.forEach((element) {
      if (element.name == CALENDAR_NAME) _calendar = element;
    });
  }

  ///
  /// Register an event
  /// @return: the event ID if success
  Future<String> registerEvent(Event event) async {
    if (!_init) await initCalendar();

    event.calendarId ??= _calendar.id;

    Result<String> _result = await _calPlugin.createOrUpdateEvent(event);

    return (_result.isSuccess ? _result.data : null);
  }

  Future<List<EventEx>> getEvents({DateTime start, DateTime end}) async {
    if (!_init) await initCalendar();

    DateTime now = DateTime.now();

    start ??= DateTime(now.year, 1, 1);
    end ??= DateTime(now.year, 12, 31);

    var result = await _calPlugin.retrieveEvents(
      _calendar.id,
      RetrieveEventsParams(
        startDate: start,
        endDate: end,
      ),
    );

    if (!result.isSuccess) return null;

    //TODO: convert to EventEx

    return result.data.toList();
  }

  Future<bool> deleteEvent(Event event) async {
    if (!_init) await initCalendar();

    // debugPrint("Deleting event: ${event.json}");

    var result = await _calPlugin.deleteEvent(
      _calendar.id,
      event.eventId,
    );

    return result.isSuccess;
  }

  // TODO: check this function again, not working
  Future<bool> deleteRecurrenceEvents(
    Event event,
    bool onlyCurrentInstance,
  ) async {
    if (!_init) await initCalendar();

    var result = await _calPlugin.deleteEventInstance(
      _calendar.id,
      event.eventId,
      event.start.millisecondsSinceEpoch,
      event.end.millisecondsSinceEpoch,
      onlyCurrentInstance,
    );

    debugPrint(
      "Remove result data: ${result.data}\nError: ${result.errorMessages}",
    );

    return result.isSuccess && result.data;
  }
}

//region Local implementation
extension EventExtension on Event {
  String get json {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['eventId'] = eventId;
    data['calendarId'] = calendarId;
    data['title'] = title;
    data['description'] = description;
    data['start'] = start;
    data['end'] = end;
    data['allDay'] = allDay;
    data['location'] = location;
    data['attendees'] = attendees?.map((a) => a.toJson())?.toList();
    data['recurrenceRule'] = recurrenceRule?.json();
    data['reminders'] = reminders?.map((r) => r.toJson())?.toList();

    return data.toString();
  }
}

extension RecurrenceRuleExtension on RecurrenceRule {
  Map<String, dynamic> json() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['totalOccurrences'] = totalOccurrences;
    data['interval'] = interval;
    data['endDate'] = endDate;
    data['recurrenceFrequency'] = recurrenceFrequency;
    data['daysOfWeek'] = daysOfWeek?.map((d) => d.value)?.toList();
    data['monthOfYear'] = monthOfYear;
    data['weekOfMonth'] = weekOfMonth;
    data['dayOfMonth'] = dayOfMonth;

    return data;
  }
}
//endregion
