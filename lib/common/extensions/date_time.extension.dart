extension DateTimeExtension on DateTime {
  String toDateString() {
    return '$day.$month.$year';
  }

  int differenceInYears(DateTime other) {
    return difference(other).inDays ~/ 365;
  }

  int differenceInMonths(DateTime other) {
    return difference(other).inDays ~/ 30;
  }
}
