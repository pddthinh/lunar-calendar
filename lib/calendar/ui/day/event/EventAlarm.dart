import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventAlarm extends StatefulWidget {
  final ValueChanged<Duration> callback;

  const EventAlarm({Key key, @required this.callback}) : super(key: key);

  @override
  State createState() => _AlarmState(callback);
}

class _AlarmState extends State<EventAlarm> {
  final ValueChanged<Duration> _callback;
  final TextEditingController _controller = TextEditingController();

  _AlarmState(this._callback);

  _AlarmMode _selectedMode = _AlarmMode.MINUTE;

  @override
  void initState() {
    super.initState();

    _controller.text = "15";
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _notifyResult() {
    if (_callback == null) return;

    var _value = int.parse(_controller.text);
    switch (_selectedMode) {
      case _AlarmMode.MINUTE:
        _callback(Duration(minutes: _value));
        break;

      case _AlarmMode.HOUR:
        _callback(Duration(hours: _value));
        break;

      case _AlarmMode.DAY:
        _callback(Duration(days: _value));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgets = [];

    _widgets.add(
      TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
      ),
    );

    _widgets.addAll(
      List.generate(_AlarmMode.values.length, (index) {
        var _mode = _AlarmMode.values[index];

        return RadioListTile<_AlarmMode>(
          title: Text(_mode.getName()),
          value: _mode,
          groupValue: _selectedMode,
          selected: _selectedMode == _mode,
          onChanged: (selected) {
            setState(() {
              _selectedMode = selected;
//              debugPrint("Selected mode: $_selectedMode");
              _notifyResult();
            });
          },
        );
      }),
    );

    _notifyResult();

    return ExpansionTile(
      tilePadding: EdgeInsets.only(left: 0, right: 0),
      leading: Icon(Icons.alarm_on_sharp),
      title: Text("${_controller.text} ${_selectedMode.getName()} before"),
      childrenPadding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
      children: _widgets,
      onExpansionChanged: (expanded) {
//        debugPrint("onExpansionChanged: expanded=$changed");
        if (!expanded) _notifyResult();
      },
    );
  }
}

//region Internal implementation
enum _AlarmMode {
  MINUTE,
  HOUR,
  DAY,
}

extension _AlarmModeEx on _AlarmMode {
  String getName() {
    switch (this) {
      case _AlarmMode.MINUTE:
        return "Minutes";

      case _AlarmMode.HOUR:
        return "Hours";

      case _AlarmMode.DAY:
        return "Days";
    }

    return null;
  }
}
//endregion
