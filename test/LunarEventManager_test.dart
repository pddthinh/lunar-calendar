import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunar_calendar/calendar/LunarEventManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Unit test for LunarEventManager
/// Need to run on device
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LunarEventManager evManager;
  SharedPreferences pref;

  group("addEventIDs", () {
    setUp(() async {
      pref = await SharedPreferences.getInstance();

      evManager = LunarEventManager();
      await evManager.init();
      expect(evManager.data.isEmpty, true);
      // debugPrint("setUp done ...");
    });

    tearDown(() async {
      await evManager.clearAll();
    });

    test("test_updateEventIDs_add_paramEmpty", () async {
      expect(await evManager.updateEventIDs(null), false);
      expect(await evManager.updateEventIDs([]), false);

      await evManager.refresh();
      // debugPrint("data: ${evManager.data}");
      expect(evManager.data.isEmpty, true);
    });

    test("test_updateEventIDs_add_dataNotExist", () async {
      var ids = ["1", "2", "3", "4"];

      expect(await evManager.updateEventIDs(ids), true);

      await evManager.refresh();
      expect(evManager.data.length, 1);
      evManager.data.assertContains(ids);
    });

    test("test_updateEventIDs_add_dataExist_1", () async {
      var id1 = ["1", "2", "3"];
      var id2 = ["5", "7", "9", "10"];
      var ids = ["4", "2", "9"];

      //region Preset the data
      await pref.setStringList("${DATA_PREFIX}1", id1);
      await pref.setStringList("${DATA_PREFIX}2", id2);

      id1.sort();
      id2.sort();

      // Verify the preset data
      await evManager.refresh();
      // debugPrint("evManager - data: ${evManager.data}");

      expect(evManager.data.length, 2);
      evManager.data.assertContains(id1);
      evManager.data.assertContains(id2);
      //endregion

      expect(await evManager.updateEventIDs(ids), true);

      // Verify the preset data
      await evManager.refresh();
      // debugPrint("evManager - data: ${evManager.data}");

      expect(evManager.data.length, 3);
      evManager.data.assertContains(["1", "3"]);
      evManager.data.assertContains(["5", "7", "10"]);
      evManager.data.assertContains(["4", "2", "9"]);
    });

    test("test_updateEventIDs_add_dataExist_2", () async {
      var id1 = ["1", "2", "3"];
      var id2 = ["5", "7", "9", "10"];
      var ids = ["4", "1", "9"];

      //region Preset the data
      await pref.setStringList("${DATA_PREFIX}1", id1);
      await pref.setStringList("${DATA_PREFIX}2", id2);

      id1.sort();
      id2.sort();

      // Verify the preset data
      await evManager.refresh();
      expect(evManager.data.length, 2);
      evManager.data.assertContains(id1);
      evManager.data.assertContains(id2);
      //endregion

      expect(await evManager.updateEventIDs(ids), true);

      // Verify the final data
      await evManager.refresh();
      expect(evManager.data.length, 3);
      evManager.data.assertContains(["2", "3"]);
      evManager.data.assertContains(["5", "7", "10"]);
      evManager.data.assertContains(["1", "4", "9"]);
    });

    test("test_updateEventIDs_add_dataExist_3", () async {
      var id1 = ["1", "2", "3"];
      var id2 = ["5", "7", "9", "10"];
      var ids = ["1", "3"];

      //region Preset the data
      await pref.setStringList("${DATA_PREFIX}1", id1);
      await pref.setStringList("${DATA_PREFIX}2", id2);

      id1.sort();
      id2.sort();

      // Verify the preset data
      await evManager.refresh();
      expect(evManager.data.length, 2);
      evManager.data.assertContains(id1);
      evManager.data.assertContains(id2);
      //endregion

      expect(await evManager.updateEventIDs(ids), true);

      // Verify the final data
      await evManager.refresh();
      expect(evManager.data.length, 3);
      evManager.data.assertContains(["2"]);
      evManager.data.assertContains(["5", "7", "9", "10"]);
      evManager.data.assertContains(["1", "3"]);
    });
  });

  group("removeEventIDs", () {
    setUp(() async {
      pref = await SharedPreferences.getInstance();

      evManager = LunarEventManager();
      await evManager.init();
      expect(evManager.data.isEmpty, true);
    });

    tearDown(() async {
      evManager.clearAll();
    });

    test("test_updateEventIDs_remove_paramEmpty", () async {
      expect(await evManager.updateEventIDs(null, isRemove: true), false);
      expect(await evManager.updateEventIDs([], isRemove: true), false);

      await evManager.refresh();
      expect(evManager.data.isEmpty, true);
    });

    test("test_updateEventIDs_remove_dataNotExist", () async {
      var id1 = ["1", "2", "3", "4"];
      expect(await evManager.updateEventIDs(id1), true);
      await evManager.refresh();

      var ids = ["5", "8"];
      expect(await evManager.updateEventIDs(ids, isRemove: true), true);

      await evManager.refresh();
      expect(evManager.data.length, 1);
      evManager.data.assertContains(id1);
    });

    test("test_updateEventIDs_remove_dataExist_1", () async {
      var id1 = ["1", "2", "3"];
      var id2 = ["5", "7", "9", "10"];

      //region Preset the data
      await pref.setStringList("${DATA_PREFIX}1", id1);
      await pref.setStringList("${DATA_PREFIX}5", id2);

      // Verify the preset data
      await evManager.refresh();
      expect(evManager.data.length, 2);
      evManager.data.assertContains(id1);
      evManager.data.assertContains(id2);
      //endregion

      expect(await evManager.updateEventIDs(id1, isRemove: true), true);

      await evManager.refresh();
      expect(evManager.data.length, 1);
      evManager.data.assertContains(id2);
    });

    test("test_updateEventIDs_remove_dataExist_2", () async {
      var id1 = ["1", "2", "3"];
      var id2 = ["5", "7", "9", "10"];

      //region Preset the data
      await pref.setStringList("${DATA_PREFIX}1", id1);
      await pref.setStringList("${DATA_PREFIX}5", id2);

      // Verify the preset data
      await evManager.refresh();
      expect(evManager.data.length, 2);
      evManager.data.assertContains(id1);
      evManager.data.assertContains(id2);
      //endregion

      expect(await evManager.updateEventIDs(["1", "10", "4"], isRemove: true),
          true);

      await evManager.refresh();
      expect(evManager.data.length, 2);
      evManager.data.assertContains(["2", "3"]);
      evManager.data.assertContains(["5", "7", "9"]);
    });
  });
}

extension SetHelper on Set<List<String>> {
  void assertContains(List<String> list) {
    expect(this.isEmpty, false);
    expect(list != null, true);

    List<String> tmp = new List.from(list);
    tmp.sort();

    var found = false;
    this.forEach((element) {
      if (found) return;
      found = listEquals(element, tmp);
    });
    expect(found, true);
  }
}
