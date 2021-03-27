import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';

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

  Future<bool> registerEvent(Event event) async {
    if (!_init) await initCalendar();

    event.calendarId ??= _calendar.id;

    Result<String> _result = await _calPlugin.createOrUpdateEvent(event);
    return _result.isSuccess;
  }

  Future<List<Event>> getEvents({DateTime start, DateTime end}) async {
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

    return result.data.toList();
  }
}
