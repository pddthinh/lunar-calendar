import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lunar_calendar/calendar/Calendar.dart';
import 'package:lunar_calendar/calendar/LunarConverter.dart';
import 'package:lunar_calendar/calendar/SwipeDetector.dart';

class DayView extends StatefulWidget {
  static const ROUTE_NAME = "/day";

  @override
  State<StatefulWidget> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  DateTime _date;

  Widget _buildDayText(BuildContext context) {
    Color _color = Colors.black;
    Weekday wd = _date.toWeekday();
    if (wd == Weekday.SUN) _color = Colors.red;

    return Center(
      child: Text(
        "${wd.getVNText()}",
        style: TextStyle(color: _color, fontSize: 60),
      ),
    );
  }

  Widget _buildDayNumber(BuildContext context) {
    return Center(
      child: Text(
        "${_date.day}",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 200),
      ),
    );
  }

  Widget _buildLunarDay(BuildContext context) {
    LunarDate lunar = SolarLunarConverter().convertSolar2Lunar(_date);
    VNLunarDay vnLunarDay = lunar.getType();
    Color ftColor;
    List<Widget> extraWidgets = [];

    if (vnLunarDay != VNLunarDay.NONE) {
      ftColor = Colors.red;

      String text = "${vnLunarDay.getVnText()}";
      if (vnLunarDay == VNLunarDay.Ram)
        text = "$text ${lunar.getVNMonthName()}";

      extraWidgets.add(Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 30),
      ));
    }

    List<Widget> rowItems = [];

    // Left column,
    rowItems.add(Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        "${lunar.getVNMonthName()}",
        style: TextStyle(fontSize: 20, color: ftColor),
      ),
      Text(
        "${lunar.day}",
        style: TextStyle(
          color: ftColor,
          fontWeight: FontWeight.bold,
          fontSize: 40,
        ),
      ),
      Text(
        "${lunar.getVNYearName()}",
        style: TextStyle(color: ftColor, fontSize: 20),
      ),
    ]));

    // Right column, if any
    if (extraWidgets.isNotEmpty) {
      rowItems.add(Flexible(
        fit: FlexFit.loose,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: extraWidgets,
        ),
      ));
    }

    return Container(
      margin: EdgeInsets.all(20),
      child: Center(
        child: Row(
          mainAxisAlignment: extraWidgets.isEmpty
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceAround,
          children: rowItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_date == null) _date = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_date.getVNMonthName()} - ${_date.year}",
        ),
      ),
      body: SwipeDetector(
        child: Container(
//          decoration: BoxDecoration(
//            border: Border.all(width: 5.0, color: Colors.black),
//            borderRadius: BorderRadius.circular(2),
//          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDayText(context),
              _buildDayNumber(context),
              _buildLunarDay(context),
            ],
          ),
        ),
        onNext: () {
          setState(() {
            _date = _date.nextDate();
          });
        },
        onPrevious: () {
          setState(() {
            _date = _date.previousDate();
          });
        },
      ),
    );
  }
}
