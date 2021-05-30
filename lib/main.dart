import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lunar_calendar/calendar/ui/day/DayView.dart';
import 'package:lunar_calendar/calendar/ui/day/event/EventDetail.dart';
import 'package:lunar_calendar/calendar/ui/month/MonthView.dart';
import 'package:lunar_calendar/global.dart';

void main() {
  runApp(Calendar());
}

class Calendar extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    pluginWrapper.initCalendar();
    lnEventManager.init();

    // Force the screen orientation
    // https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final MonthView _monthView = MonthView();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Lunar Calendar",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _monthView,
      routes: {
        MonthView.ROUTE_NAME: (context) => _monthView,
        DayView.ROUTE_NAME: (context) => DayView(),
        EventDetail.ROUTE_NAME: (context) => EventDetail(),
      },
    );
  }
}
