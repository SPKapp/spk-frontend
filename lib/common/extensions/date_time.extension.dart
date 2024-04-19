import 'package:intl/intl.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');
final _timeFormat = DateFormat('HH:mm');
final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

extension DateTimeExtension on DateTime {
  String toDateString() {
    return _dateFormat.format(this);
  }

  String toTimeString() {
    return _timeFormat.format(this);
  }

  String toDateTimeString() {
    return _dateTimeFormat.format(this);
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
