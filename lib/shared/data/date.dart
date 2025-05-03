import 'package:flutter/foundation.dart';

DateTime _now = DateTime.now();
DateTime today = kDebugMode
    // ? DateTime.parse("2024-11-20")
    ? DateTime(2025,5,3)
    : DateTime(_now.year, _now.month, _now.day);
bool isToday(DateTime date) {
  return (date.day == today.day &&
      date.month == today.month &&
      date.year == today.year);
}
