import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lunar_calendar/calendar/Calendar.dart';
import 'package:lunar_calendar/calendar/SwipeDetector.dart';
import 'package:lunar_calendar/calendar/ui/day/event/EventDetail.dart';
import 'package:lunar_calendar/calendar/ui/day/event/EventList.dart';

class DayView extends StatefulWidget {
  static const ROUTE_NAME = "/day";

  @override
  State<StatefulWidget> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  DateInfo _dInfo;
  bool _shouldRefresh = false;

  //region Build Day Info
  Widget _buildDetailDayText(BuildContext context) {
    Color _color = Colors.black;
    Weekday wd = _dInfo.date.toWeekday();
    if (wd == Weekday.SUN) _color = Colors.red;

    double size = 60;
    size = 30;

    return Center(
      child: Text(
        "${wd.getVNText()}",
        style: TextStyle(color: _color, fontSize: size),
      ),
    );
  }

  Widget _buildDetailDayNumber(BuildContext context) {
    double size = 200;
    size = 80;

    Color _color = Colors.black;
    if (_dInfo.date.toWeekday() == Weekday.SUN) _color = Colors.red;

    return Center(
      child: Text(
        "${_dInfo.date.day}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size,
          color: _color,
        ),
      ),
    );
  }

  Widget _buildDetailLunarDay(BuildContext context) {
    VNLunarDay vnLunarDay = _dInfo.lunar.getType();
    Color ftColor;
    String lunarDay = "${_dInfo.lunar.day}";

    if (vnLunarDay != VNLunarDay.NONE) {
      ftColor = Colors.red;

      lunarDay = "${vnLunarDay.getVnText()} ($lunarDay)";
    }

    return Container(
      margin: EdgeInsets.all(10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Text(
                "${_dInfo.lunar.getVNYearName()}",
                style: TextStyle(color: ftColor, fontSize: 18),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Text(
                "$lunarDay",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ftColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Text(
                "${_dInfo.lunar.getVNMonthName()}",
                style: TextStyle(color: ftColor, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayInfo(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDetailDayText(context),
          _buildDetailDayNumber(context),
          Container(
            padding: EdgeInsets.only(top: 40),
            child: _buildDetailLunarDay(context),
          ),
        ],
      ),
    );
  }

  //endregion

  DateInfo _getExactTime() {
    DateTime now = DateTime.now();

    return DateInfo(
      date: DateTime(
        _dInfo.date.year,
        _dInfo.date.month,
        _dInfo.date.day,
        now.hour,
        now.minute,
        now.second,
      ),
    );
  }

  //region Main View
  @override
  Widget build(BuildContext context) {
    _dInfo ??= ModalRoute.of(context).settings.arguments;

    return WillPopScope(
      // Catch the button back and notify parent to refresh if needed
      onWillPop: () async {
        // debugPrint("$this ==> onWillPop, shouldRefresh: $_shouldRefresh");
        Navigator.pop(context, _shouldRefresh);

        return false;
      },

      // The main view
      child: Scaffold(
        appBar: AppBar(
          title: Text("${_dInfo.date.getVNMonthName()} - ${_dInfo.date.year}"),
        ),
        body: SwipeDetector(
          child: Row(
            children: [
              Expanded(
                child: Container(child: _buildDayInfo(context)),
              ),
              EventList(
                date: _dInfo.date,
                onUpdated: (updated) => _shouldRefresh = updated,
              ),
            ],
          ),
          onNext: () => setState(() => _dInfo.toNextDate()),
          onPrevious: () => setState(() => _dInfo.toPreviousDate()),
        ),
        floatingActionButton: FloatingActionButton(
          mini: true,
          child: Icon(Icons.add_alarm_rounded),
          onPressed: () => Navigator.pushNamed(
            context,
            EventDetail.ROUTE_NAME,
            arguments: _getExactTime(),
            // DetailParam(dInfo: _getExactTime()),
          ).then(
            (value) {
              if (value == null || !value) return;

              // Refresh the page to load new event, if any
              setState(() => _shouldRefresh = true);
            },
          ),
        ),
      ),
    );
  }
//endregion
}
