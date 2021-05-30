import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String DATA_PREFIX = "DT-";

///
/// LunarEvent manager to manage lunar event recurrent:
/// Group of the related recurrent events is saved in the preference
class LunarEventManager {
  SharedPreferences _pref;
  Set<List<String>> _mIdData;

  Set<List<String>> get data {
    return _mIdData;
  }

  Future<void> init() async {
    if (_mIdData != null) return;

    await refresh();
  }

  Future<void> refresh() async {
    _mIdData = new HashSet();
    Map<String, List<String>> _data = await _loadLunarEventIDs();
    if (_data != null) _mIdData.addAll(_data.values);
  }

  Future<void> clearAll() async {
    await init();

    if (_mIdData.isEmpty) return;

    await _pref.clear();
    _mIdData.clear();
  }

  ///
  /// In order to save the event ids list:
  ///   - unlink (remove) all the ids in the new list from the existing list (if any)
  ///   - save all the data back to the preferences
  ///
  /// NOTE: this function is not thread safe!
  Future<bool> updateEventIDs(
    List<String> ids, {
    isRemove,
  }) async {
    bool blResult = false;

    do {
      if (ids == null || ids.isEmpty) break;

      await init();
      ids.sort();

      ids.forEach((nID) {
        _mIdData.forEach((lstId) {
          lstId.remove(nID);
        });
      });

      _mIdData.removeWhere((element) => element.isEmpty);

      // if (isRemove != null && !isRemove) _mIdData.add(ids);
      if (isRemove == null || !isRemove) _mIdData.add(ids);

      // Memory data is updated, now sync with the pref

      // Clear all data first
      await _pref.clear();
      // debugPrint("mem data: $_mIdData");

      var counter = 0;
      await Future.forEach(_mIdData, (lstId) async {
        await _pref.setStringList("$DATA_PREFIX$counter", lstId);
        counter++;
        // debugPrint("Counter: $counter --> $lstId");
      });

      blResult = true;
    } while (false);

    return blResult;
  }

  //region Internal implementation
  Future<void> _getPref() async {
    _pref = await SharedPreferences.getInstance();
  }

  ///
  /// Load all Lunar event IDs from SharedPreference
  ///
  Future<Map<String, List<String>>> _loadLunarEventIDs() async {
    if (_pref == null) await _getPref();

    Map<String, List<String>> result;

    do {
      // Load all keys
      Set<String> keys = _pref.getKeys();
      // debugPrint("Pref keys: $keys");
      if (keys == null || keys.isEmpty) break;

      result = new HashMap();
      keys.forEach((key) {
        if (!key.startsWith(DATA_PREFIX)) return;

        List<String> data = _pref.getStringList(key);
        if (data == null || data.isEmpty) return;

        data.sort();
        // debugPrint("$key --> Sorted: $data");

        result[key] = data;
      });
    } while (false);

    if (result == null) result = HashMap();

    return result;
  }
//endregion
}

class EventEx extends Event {
  List<String> lunarRecurrenceIds;

  EventEx(
    String calendarId, {
    eventId,
    title,
    start,
    end,
    description,
    attendees,
    recurrenceRule,
    allDay = false,
  }) : super(
          calendarId,
          eventId: eventId,
          title: title,
          start: start,
          end: end,
          description: description,
          attendees: attendees,
          recurrenceRule: recurrenceRule,
          allDay: allDay,
        );
}
