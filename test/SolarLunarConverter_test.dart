import 'package:lunar_calendar/calendar/Calendar.dart';
import 'package:lunar_calendar/calendar/LunarConverter.dart';

void main() {
  DateTime inDate = DateTime.now();
  int steps = 15;
  int max = 500;
  int count = 0;

  SolarLunarConverter helper = new SolarLunarConverter();
  DateTime solar;
  LunarDate lunar;

  do {
    lunar = helper.convertSolar2Lunar(inDate);
    solar = helper.convertLunar2Solar(lunar);

    assert(solar.day == inDate.day);
    assert(solar.month == inDate.month);
    assert(solar.year == inDate.year);

    print(
        "Result: ${inDate.day}/${inDate.month}/${inDate.year} --> ${lunar.toString()}");

    count += steps;
    inDate = inDate.add(new Duration(days: count));
  } while (count < max);
}
