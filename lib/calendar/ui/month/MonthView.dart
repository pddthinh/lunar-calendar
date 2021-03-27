import 'dart:ui';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lunar_calendar/calendar/Calendar.dart';
import 'package:lunar_calendar/calendar/LunarConverter.dart';
import 'package:lunar_calendar/calendar/SwipeDetector.dart';
import 'package:lunar_calendar/calendar/ui/day/DayView.dart';
import 'package:lunar_calendar/global.dart';

class MonthView extends StatefulWidget {
  static const ROUTE_NAME = "/month";

  @override
  State<StatefulWidget> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  DateTime _startDate;

  void _toCurrentMonth() {
    DateTime now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
  }

  void _test() async {
    List<Event> _events = await pluginWrapper.getEvents();
    _events.forEach((element) {
      debugPrint("[${element.start} --> ${element.end}]: ${element.title}");
    });
  }

  @override
  void initState() {
    _test();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_startDate == null) _toCurrentMonth();

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat("MMMM - yyyy").format(_startDate)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            SwipeDetector(
              child: _Detail(startDate: _startDate),
              onNext: () {
                setState(() {
                  _startDate = _startDate.nextMonth();
                });
              },
              onPrevious: () {
                setState(() {
                  _startDate = _startDate.previousMonth();
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        child: Icon(Icons.adjust_rounded),
        onPressed: () {
          setState(() {
            _toCurrentMonth();
          });

          _test();
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  String _getDayInWeek(int idx) {
    Weekday wd;

    Weekday.values.forEach((element) {
      if (element.index == idx) wd = element;
    });

    return describeEnum(wd);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Row(
        children: List.generate(
          Weekday.values.length,
          (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
                color: Colors.black12,
                height: 50,
                child: Center(
                  child: Text(
                    _getDayInWeek(index),
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  static const int _NUMBER_OF_ROW = 6;
  final DateTime startDate;

  const _Detail({Key key, this.startDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    double _totalHeight = _mediaQuery.size.height - 170;
    double _height = _totalHeight / _NUMBER_OF_ROW;

    int _dayCounter = 0;

    return Container(
      padding: EdgeInsets.all(4),
      child: Table(
        children: List.generate(
          _NUMBER_OF_ROW,
          (rowIdx) {
            return TableRow(
              // 0 - 6
              children: List.generate(
                Weekday.values.length,
                (wdIdx) {
                  DateTime cellDate;

                  do {
                    // The 1st row
                    if (rowIdx == 0 && (wdIdx < startDate.toWeekday().index))
                      break;

                    cellDate = startDate.add(Duration(days: _dayCounter));
                    _dayCounter++;

                    if (cellDate.month != startDate.month) cellDate = null;
                  } while (false);

                  return new _Cell(height: _height, date: cellDate);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final double height;
  final DateTime date;

  const _Cell({
    Key key,
    this.height,
    this.date,
  }) : super(key: key);

  Weekday _getWeekday() {
    return (date != null ? date.toWeekday() : null);
  }

  Widget _buildSonarDateText(BuildContext context) {
    Color _color = Colors.black;
    if (_getWeekday() == Weekday.SUN) _color = Colors.red;

    return Text(
      "${date.day}",
      style:
          TextStyle(color: _color, fontWeight: FontWeight.bold, fontSize: 30),
    );
  }

  Widget _buildLunarDateText(BuildContext context) {
    FontWeight ftWeight;
    Color ftColor = Colors.indigo;

    LunarDate lunar = SolarLunarConverter().convertSolar2Lunar(date);
    String lunarText = "${lunar.day}";

    VNLunarDay vnLunarDay = lunar.getType();
    if (vnLunarDay != VNLunarDay.NONE) {
      ftWeight = FontWeight.bold;
      ftColor = Colors.red;
      lunarText += "/${lunar.month}";
      if (lunar.leap != 0) lunarText += "(L)";
    }

    return FittedBox(
      child: Text(
        lunarText,
        textAlign: TextAlign.center,
        style: TextStyle(color: ftColor, fontSize: 18, fontWeight: ftWeight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Empty cell
    if (date == null) return Container(height: height);

    Decoration _highlight;
    if (date.isSameDay(DateTime.now())) {
      _highlight = BoxDecoration(
        color: Colors.black12,
        border: Border.all(width: 3.0, color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          DayView.ROUTE_NAME,
          arguments: DateInfo(date: date),
        );
      },
      child: Container(
        margin: EdgeInsets.all(2),
        height: height,
        decoration: _highlight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSonarDateText(context),
              _buildLunarDateText(context),
            ],
          ),
        ),
      ),
    );
  }
}
