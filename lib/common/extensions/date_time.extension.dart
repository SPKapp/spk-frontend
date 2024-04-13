import 'package:intl/intl.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

extension DateTimeExtension on DateTime {
  String toDateString() {
    return _dateFormat.format(this);
  }

  static DateTime parseFromDate(String date) {
    return _dateFormat.parseUtc(date);
  }

  int differenceInYears(DateTime other) {
    return difference(other).inDays ~/ 365;
  }

  int differenceInMonths(DateTime other) {
    return difference(other).inDays ~/ 30;
  }
}
