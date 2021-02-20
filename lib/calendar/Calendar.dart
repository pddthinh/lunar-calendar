enum Weekday { SUN, MON, TUE, WED, THU, FRI, SAT }

enum VNLunarDay {
  NONE,
  Mung1,
  Mung2,
  Mung3,
  Ram,
  GioTo,
  PhatDan,
  DoanNgo,
  VuLan,
  TetTrungThu,
  DuaOngTao
}

const CHI = [
  "Tí",
  "Sửu",
  "Dần",
  "Mẹo",
  "Thìn",
  "Tị",
  "Ngọ",
  "Mùi",
  "Thân",
  "Dậu",
  "Tuất",
  "Hợi"
];
const CAN = [
  "Giáp",
  "Ất",
  "Bính",
  "Đinh",
  "Mậu",
  "Kỷ",
  "Canh",
  "Tân",
  "Nhâm",
  "Quý"
];
const VN_MONTH = [
  "Giêng",
  "Hai",
  "Ba",
  "Tư",
  "Năm",
  "Sáu",
  "Bảy",
  "Tám",
  "Chín",
  "Mười",
  "Mười Một",
  "Mười Hai"
];

class LunarDate {
  int day;
  int month;
  int year;
  int leap;
  double timeZone;

  LunarDate(int d, int m, int y, int l) {
    day = d;
    month = m;
    year = y;
    leap = l;

    timeZone = DateTime.now().timeZoneOffset.inHours.toDouble();
  }

  void setTimeZone(double timezone) {
    timeZone = timezone;
  }

  String toString() {
    String out = "$day/$month/$year";

    return (leap == 0 ? out : "$out (L)");
  }

  /// Refer:
  ///   http://www.informatik.uni-leipzig.de/~duc/amlich/
  VNLunarDay getType() {
    VNLunarDay _day = VNLunarDay.NONE;

    switch (day) {
      case 1:
        _day = VNLunarDay.Mung1;
        break;

      case 2:
        if (month == 1) _day = VNLunarDay.Mung2;
        break;

      case 3:
        if (month == 1) _day = VNLunarDay.Mung3;
        break;

      case 5:
        if (month == 5) _day = VNLunarDay.DoanNgo;
        break;

      case 10:
        if (month == 3) _day = VNLunarDay.GioTo;
        break;

      case 15:
        {
          _day = VNLunarDay.Ram;
          switch (month) {
            case 4:
              {
                _day = VNLunarDay.PhatDan;
                break;
              }

            case 7:
              {
                _day = VNLunarDay.VuLan;
                break;
              }

            case 8:
              {
                _day = VNLunarDay.TetTrungThu;
                break;
              }
          }

          break;
        }

      case 23:
        if (month == 12) _day = VNLunarDay.DuaOngTao;
        break;
    }

    return _day;
  }

  ///
  /// Retrieve the Vietnamese name of the year
  ///
  String getVNYearName() {
    String _can = CAN[(year + 6) % 10];
    String _chi = CHI[(year + 8) % 12];
    return "Năm $_can $_chi";
  }

  String getVNMonthName() {
    int idx = month - 1;
    return idx == 11 ? "Tháng Chạp" : "Tháng ${VN_MONTH[idx]}";
  }
}

extension DateTimeEx on DateTime {
  bool isSameDay(DateTime other) {
    return (year == other.year) && (month == other.month) && (day == other.day);
  }

  DateTime nextDate() {
    return add(const Duration(days: 1));
  }

  DateTime previousDate() {
    return subtract(const Duration(days: 1));
  }

  DateTime nextMonth() {
    return DateTime(year, month + 1);
  }

  DateTime previousMonth() {
    return DateTime(year, month - 1);
  }

  Weekday toWeekday() {
    switch (weekday) {
      case DateTime.monday:
        return Weekday.MON;

      case DateTime.tuesday:
        return Weekday.TUE;

      case DateTime.wednesday:
        return Weekday.WED;

      case DateTime.thursday:
        return Weekday.THU;

      case DateTime.friday:
        return Weekday.FRI;

      case DateTime.saturday:
        return Weekday.SAT;
    }

    return Weekday.SUN;
  }

  String getVNMonthName() {
    return "Tháng ${VN_MONTH[month - 1]}";
  }
}

extension WeekdayEx on Weekday {
  String getText() {
    switch (this) {
      case Weekday.MON:
        return "Monday";
      case Weekday.TUE:
        return "Tuesday";
      case Weekday.WED:
        return "Wednesday";
      case Weekday.THU:
        return "Thursday";
      case Weekday.FRI:
        return "Friday";
      case Weekday.SAT:
        return "Saturday";
      default:
        return "Sunday";
    }
  }

  String getVNText() {
    switch (this) {
      case Weekday.MON:
        return "Thứ Hai";
      case Weekday.TUE:
        return "Thứ Ba";
      case Weekday.WED:
        return "Thứ Tư";
      case Weekday.THU:
        return "Thứ Năm";
      case Weekday.FRI:
        return "Thứ Sáu";
      case Weekday.SAT:
        return "Thứ Bảy";
      default:
        return "Chủ Nhật";
    }
  }
}

extension VNLunarDayEx on VNLunarDay {
  String getVnText() {
    switch (this) {
      case VNLunarDay.Mung1:
        return "Mùng Một";

      case VNLunarDay.Mung2:
        return "Mùng Hai";

      case VNLunarDay.Mung3:
        return "Mùng Ba";

      case VNLunarDay.Ram:
        return "Rằm";

      case VNLunarDay.GioTo:
        return "Giổ Tổ";

      case VNLunarDay.PhatDan:
        return "Phật Đản";

      case VNLunarDay.DoanNgo:
        return "Tết Đoan Ngọ";

      case VNLunarDay.VuLan:
        return "Vu Lan";

      case VNLunarDay.TetTrungThu:
        return "Tết Trung Thu";

      case VNLunarDay.DuaOngTao:
        return "Đưa Ông Táo";

      default:
        return null;
    }
  }
}
