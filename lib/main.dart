import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lunar_calendar/calendar/ui/day/DayView.dart';
import 'package:lunar_calendar/calendar/ui/month/MonthView.dart';

void main() {
  runApp(Calendar());
}

class Calendar extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Force the screen orientation
    // https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Lunar Calendar",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MonthView(),
      routes: {
        MonthView.ROUTE_NAME: (context) => MonthView(),
        DayView.ROUTE_NAME: (context) => DayView(),
      },
    );
  }
}
