import 'package:lunar_calendar/calendar/CalendarPluginWrapper.dart';
import 'package:lunar_calendar/calendar/LunarEventManager.dart';

CalendarPluginWrapper pluginWrapper = CalendarPluginWrapper();
LunarEventManager lnEventManager = LunarEventManager();

class Config {
  // ignore: non_constant_identifier_names
  // TODO: Add Settings screen to show this config
  static final DateTime RECURRENCE_END = DateTime(
    DateTime.now().year,
    12, // DateTime.now().month,
    31,
    23,
    59,
    59,
  );
}
