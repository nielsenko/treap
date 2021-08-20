import 'package:flutter/material.dart';

extension IntEx on int {
  String pad(int digits) => '${toString().padLeft(digits, '0')}';
  String get two => pad(2);
}

extension DateTimeEx on DateTime {
  String get yMdhm => '$year-${month.two}-${day.two} ${hour.two}:${minute.two}';

  DateTime copyWidth({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
  }) =>
      DateTime(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
      );

  DateTime offset({
    int? years,
    int? months,
    int? days,
    int? hours,
    int? minutes,
  }) =>
      this.copyWidth(
        year: year + (years ?? 0),
        month: month + (months ?? 0),
        day: day + (days ?? 0),
        hour: hour + (hours ?? 0),
        minute: minute + (minutes ?? 0),
      );
}

extension TimeOfDayEx on TimeOfDay {
  String get hm => '${hour.two}:${minute.two}';
}

extension DurationEx on Duration {
  String get hm => '${(inMinutes ~/ 60).two}:${(inMinutes % 60).two}';
}
