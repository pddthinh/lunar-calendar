import 'dart:math' as Math;

import 'package:lunar_calendar/calendar/Calendar.dart';

/// Refer:
///   http://www.informatik.uni-leipzig.de/~duc/amlich/VietCalendar.java
class SolarLunarConverter {
  int _toInt(double x) {
    return x.floor();
  }

  int _jdFromDate(int dd, int mm, int yy) {
    int a = _toInt((14 - mm) / 12);
    int y = yy + 4800 - a;
    int m = mm + 12 * a - 3;

    int jdTmp = dd + _toInt((153 * m + 2) / 5) + 365 * y + _toInt(y / 4);
    int jd = jdTmp - _toInt(y / 100) + _toInt(y / 400) - 32045;
    if (jd < 2299161) jd = jdTmp - 32083;

    return jd;
  }

  double _newMoon(int k) {
    // Time in Julian centuries from 1900 January 0.5
    double t = k / 1236.85;
    double t2 = Math.pow(t, 2);
    double t3 = Math.pow(t, 3);
    double dr = Math.pi / 180;
    double jd1 =
        2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;

    // Mean new moon
    jd1 += 0.00033 * Math.sin((166.56 + 132.87 * t - 0.009173 * t2) * dr);

    // Sun's mean anomaly
    double M = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;

    // Moon's mean anomaly
    double mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;

    // Moon's argument of latitude
    double F = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;

    double c1 = (0.1734 - 0.000393 * t) * Math.sin(M * dr) +
        0.0021 * Math.sin(2 * dr * M);

    c1 -= 0.4068 * Math.sin(mpr * dr) + 0.0161 * Math.sin(dr * 2 * mpr);
    c1 -= 0.0004 * Math.sin(dr * 3 * mpr);
    c1 += 0.0104 * Math.sin(dr * 2 * F) - 0.0051 * Math.sin(dr * (M + mpr));
    c1 -=
        0.0074 * Math.sin(dr * (M - mpr)) + 0.0004 * Math.sin(dr * (2 * F + M));
    c1 -= 0.0004 * Math.sin(dr * (2 * F - M)) -
        0.0006 * Math.sin(dr * (2 * F + mpr));
    c1 += 0.0010 * Math.sin(dr * (2 * F - mpr)) +
        0.0005 * Math.sin(dr * (2 * mpr + M));

    double delTat = -0.000278 + 0.000265 * t + 0.000262 * t2;
    if (t < -11) {
      delTat = 0.001 +
          0.000839 * t +
          0.0002261 * t2 -
          0.00000845 * t3 -
          0.000000081 * t * t3;
    }

    return (jd1 + c1 - delTat);
  }

  int _getNewMoonDay(int k, double timeZone) {
    return _toInt(_newMoon(k) + 0.5 + timeZone / 24);
  }

  int _getLunarMonth11(int yy, double timeZone) {
    double off = _jdFromDate(31, 12, yy) - 2415021.076998695;
    int k = _toInt(off / 29.530588853);
    int nm = _getNewMoonDay(k, timeZone);

    int sunLong = _toInt(_getSunLongitude(nm, timeZone) / 30);
    if (sunLong >= 9) nm = _getNewMoonDay(k - 1, timeZone);

    return nm;
  }

  double _getSunLongitude(int dayNumber, double timeZone) {
    double jdn = dayNumber - 0.5 - timeZone / 24;

    // Time in Julian centuries from 2000-01-01 12:00:00 GMT
    double t = (jdn - 2451545.0) / 36525;
    double t2 = t * t;

    // degree to radian
    double dr = Math.pi / 180;

    // mean anomaly, degree
    double M =
        357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;

    // mean longitude, degree
    double l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;

    double dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * Math.sin(dr * M);
    dl += (0.019993 - 0.000101 * t) * Math.sin(dr * 2 * M) +
        0.000290 * Math.sin(dr * 3 * M);

    // true longitude, degree
    double L = l0 + dl;

    // Normalize to (0, 360)
    L -= 360 * (_toInt(L / 360));

    return L;
  }

  int _getLeapMonthOffset(int a11, double timeZone) {
    int k = _toInt(0.5 + (a11 - 2415021.076998695) / 29.530588853);
    int last; // Month 11 contains point of sun longitude 3*PI/2 (December solstice)
    int i = 1; // We start with the month following lunar month 11
    int newMoonDay = _getNewMoonDay(k + i, timeZone);
    double sunLongitude = _getSunLongitude(newMoonDay, timeZone);
    int arc = _toInt(sunLongitude / 30);

    do {
      last = arc;
      i++;
      arc = _toInt(
          _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone) / 30);
    } while (arc != last && i < 14);

    return i - 1;
  }

  DateTime _jdToDate(int jd) {
    int a, b, c;
    if (jd > 2299160) {
      // After 5/10/1582, Gregorian calendar
      a = jd + 32044;
      b = _toInt((4 * a + 3) / 146097);
      c = a - _toInt((b * 146097) / 4);
    } else {
      b = 0;
      c = jd + 32082;
    }

    int d = _toInt((4 * c + 3) / 1461);
    int e = c - _toInt((1461 * d) / 4);
    int m = _toInt((5 * e + 2) / 153);

    int day = e - _toInt((153 * m + 2) / 5) + 1;
    int month = m + 3 - 12 * _toInt((m / 10));
    int year = b * 100 + d - 4800 + _toInt(m / 10);

    return new DateTime(year, month, day);
  }

  LunarDate convertSolar2Lunar(DateTime date) {
    int dd = date.day;
    int mm = date.month;
    int yy = date.year;
    double timeZone = date.timeZoneOffset.inHours.toDouble();

    int lunarDay, lunarMonth, lunarYear, lunarLeap;

    int dayNumber = _jdFromDate(dd, mm, yy);
    int k = _toInt((dayNumber - 2415021.076998695) / 29.530588853);
    int monthStart = _getNewMoonDay(k + 1, timeZone);
    if (monthStart > dayNumber) monthStart = _getNewMoonDay(k, timeZone);

    int a11 = _getLunarMonth11(yy, timeZone);
    int b11 = a11;
    if (a11 >= monthStart) {
      lunarYear = yy;
      a11 = _getLunarMonth11(yy - 1, timeZone);
    } else {
      lunarYear = yy + 1;
      b11 = _getLunarMonth11(yy + 1, timeZone);
    }

    lunarDay = dayNumber - monthStart + 1;
    int diff = _toInt((monthStart - a11) / 29);
    lunarLeap = 0;
    lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
      int leapMonthDiff = _getLeapMonthOffset(a11, timeZone);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) lunarLeap = 1;
      }
    }

    if (lunarMonth > 12) lunarMonth -= 12;

    if (lunarMonth >= 11 && diff < 4) lunarYear -= 1;

    return new LunarDate(lunarDay, lunarMonth, lunarYear, lunarLeap);
  }

  DateTime convertLunar2Solar(LunarDate date) {
    int lunarDay = date.day;
    int lunarMonth = date.month;
    int lunarYear = date.year;
    int lunarLeap = date.leap;
    double timeZone = date.timeZone;

    int a11, b11;
    if (lunarMonth < 11) {
      a11 = _getLunarMonth11(lunarYear - 1, timeZone);
      b11 = _getLunarMonth11(lunarYear, timeZone);
    } else {
      a11 = _getLunarMonth11(lunarYear, timeZone);
      b11 = _getLunarMonth11(lunarYear + 1, timeZone);
    }

    int k = _toInt(0.5 + (a11 - 2415021.076998695) / 29.530588853);
    int off = lunarMonth - 11;
    if (off < 0) off += 12;

    if (b11 - a11 > 365) {
      int leapOff = _getLeapMonthOffset(a11, timeZone);
      int leapMonth = leapOff - 2;
      if (leapMonth < 0) leapMonth += 12;

      if (lunarLeap != 0 && lunarMonth != leapMonth) {
        print("Invalid input!");
        return null;
      }

      if (lunarLeap != 0 || off >= leapOff) off += 1;
    }

    int monthStart = _getNewMoonDay(k + off, timeZone);
    return _jdToDate(monthStart + lunarDay - 1);
  }
}
