import 'dart:ui';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunar_calendar/calendar/Calendar.dart';
import 'package:lunar_calendar/calendar/ui/day/event/EventAlarm.dart';
import 'package:lunar_calendar/global.dart';

class AddEventScreen extends StatefulWidget {
  static const ROUTE_NAME = "/addEvent";

  @override
  State createState() => AddEventState();
}

class AddEventState extends State<AddEventScreen> {
  //region Member variables
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDetail = TextEditingController();

  DateInfo _dStart;
  DateInfo _dEnd;

  bool _isAllDay;
  _RepeatMode _repeatMode;
  Duration _alarmDuration;

  //endregion

  //region Override functions
  @override
  void initState() {
    super.initState();

    _isAllDay = false;
    _repeatMode = _RepeatMode.NoRepeat;
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    _controllerDetail.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dStart == null) {
      _setStartDate(ModalRoute.of(context).settings.arguments);
      debugPrint("Received date: $_dStart");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Register an event"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              // Title
              TextFormField(
                decoration: const InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Event title",
                ),
                maxLines: 1,
                controller: _controllerTitle,
              ),

              // Repeat settings
              _buildRepeatRow(context),

              // Duration settings
              _buildDurationInfo(context),

              // Alarm settings
              _buildAlarmInfo(context),

              // Detail
              TextFormField(
                decoration: const InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Event detail",
                ),
                minLines: 5,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                controller: _controllerDetail,
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _registerEvent(context);
            },
          ),
        ),
      ],
    );
  }

  //endregion

  //region Inner Widgets
  Widget _buildRepeatRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListTileTheme(
              contentPadding: EdgeInsets.only(left: 5),
              child: SwitchListTile(
                title: Text(
                  "All day",
                  style: TextStyle(
                    fontStyle: _isAllDay ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                value: _isAllDay,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (newValue) {
                  setState(() {
                    _isAllDay = newValue;
                  });
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 10),
            child: DropdownButton<_RepeatMode>(
              value: _repeatMode,
              onChanged: (value) {
                setState(() {
                  _repeatMode = value;
                });
              },
              items:
                  _RepeatMode.values.map<DropdownMenuItem<_RepeatMode>>((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(
                    mode.name(),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationInfo(BuildContext context) {
    var _showLunar = (_repeatMode == _RepeatMode.VNLunarMonthly);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Colors.black12),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            child: _EventDateTime(
              dateInf: _dStart,
              showLunar: _showLunar,
              showDetail: !_isAllDay,
            ),
            onTap: () {
              _showDatePicker(context, _dStart.date, (value) {
                setState(() {
                  _setStartDate(
                    DateInfo(date: value),
                  );
                });
              });
            },
          ),
          Text(
            " > ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            child: _EventDateTime(
              dateInf: _dEnd,
              showLunar: _showLunar,
              showDetail: !_isAllDay,
            ),
            onTap: () {
              _showDatePicker(context, _dEnd.date, (value) {
                setState(() {
                  _dEnd = DateInfo(date: value);
                });
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: EventAlarm(
        callback: (duration) {
          _alarmDuration = duration;
          debugPrint("Alarm duration: $_alarmDuration");
        },
      ),
    );
  }

  //endregion

  //region Internal functions
  void _setStartDate(DateInfo value) {
    _dStart = value;

    DateTime _end = value.date.add(Duration(hours: 1));
    _dEnd = DateInfo(date: _end);
  }

  void _showDatePicker(
    BuildContext context,
    DateTime selectedDate,
    ValueChanged<DateTime> callback,
  ) {
    int _minInterval = 15;
    int _initMin = (selectedDate.minute % _minInterval == 0
        ? selectedDate.minute
        : (_minInterval * (selectedDate.minute / _minInterval + 1).toInt()));

    DateTime _initDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedDate.hour,
      _initMin,
    );
    debugPrint("Init date: $_initDate");

    showModalBottomSheet(
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height / 3,
        child: CupertinoDatePicker(
          mode: _isAllDay
              ? CupertinoDatePickerMode.date
              : CupertinoDatePickerMode.dateAndTime,
          initialDateTime: _initDate,
          minimumYear: _initDate.year,
          minuteInterval: _minInterval,
          onDateTimeChanged: callback,
        ),
      ),
    );
  }

  void _registerEvent(BuildContext context) async {
    Event event = Event(
      null,
      title: _controllerTitle.text,
      description: _controllerDetail.text,
      start: _dStart.date,
      end: _dEnd.date,
      allDay: _isAllDay,
    );
    event.reminders = [Reminder(minutes: _alarmDuration.inMinutes)];

    String message = "Event registered successfully";
    bool isRegistered = await pluginWrapper.registerEvent(event);
    if (!isRegistered) message = "Failed to register the event!";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );

    Navigator.of(context).pop(isRegistered);
  }
//endregion
}

//region Internal implementation
class _EventDateTime extends StatelessWidget {
  final DateInfo dateInf;
  final bool showLunar;
  final bool showDetail;

  static const FORMAT_DATE = "EEE, dd-MM-yyyy";
  static const FORMAT_TIME = "hh:mm (aaa)";

  const _EventDateTime({
    Key key,
    @required this.dateInf,
    this.showLunar,
    this.showDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _padding = EdgeInsets.only(bottom: 8);
    LunarDate _lunar = dateInf.lunar;

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: showDetail,
            child: Container(
              padding: _padding,
              child: Text(
                DateFormat(FORMAT_DATE).format(dateInf.date),
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
              ),
            ),
          ),
          Container(
            padding: showDetail ? _padding : null,
            child: Text(
              DateFormat(showDetail ? FORMAT_TIME : FORMAT_DATE)
                  .format(dateInf.date),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Visibility(
            visible: showLunar,
            child: Container(
              padding: !showDetail ? EdgeInsets.only(top: 8) : null,
              child: Column(
                children: [
                  Text("Ngày ${_lunar.day} - ${_lunar.getVNMonthName()}"),
                  Text(_lunar.getVNYearName()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _RepeatMode {
  NoRepeat,
  Daily,
  Weekly,
  Monthly,
  VNLunarMonthly,
}

extension _RepeatModeEx on _RepeatMode {
  String name() {
    switch (this) {
      case _RepeatMode.NoRepeat:
        return "No Repeat";

      case _RepeatMode.Daily:
        return "Daily";

      case _RepeatMode.Weekly:
        return "Weekly";

      case _RepeatMode.Monthly:
        return "Monthly";

      case _RepeatMode.VNLunarMonthly:
        return "Vietnamese Lunar Monthly";
    }

    return null;
  }
}
//endregion
