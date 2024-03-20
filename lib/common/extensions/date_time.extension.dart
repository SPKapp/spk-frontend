extension DateTimeExtension on DateTime {
  String toDateString() {
    return '$year-${month.toString().padLeft(2, '0')}-$day';
  }

  int differenceInYears(DateTime other) {
    return difference(other).inDays ~/ 365;
  }

  int differenceInMonths(DateTime other) {
    return difference(other).inDays ~/ 30;
  }
}
