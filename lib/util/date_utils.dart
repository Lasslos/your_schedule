String convertToUntisDate(DateTime date) {
  return (date.year >= 1000 ? date.year.toString() : "1970") +
      (date.month < 10 ? '0${date.month}' : date.month.toString()) +
      (date.day < 10 ? '0${date.day}' : date.day.toString()).toString();
}

DateTime convertToDateTime(String untisDate) {
  return DateTime.parse(untisDate);
}

int daysSinceEpoch(int timestamp) {
  return (timestamp / (1000 * 60 * 60 * 24)).floor();
}

bool dateInBetweenDays(
    {required DateTime from, required DateTime to, DateTime? current}) {
  int fromD = daysSinceEpoch(from.millisecondsSinceEpoch);
  int toD = daysSinceEpoch(to.millisecondsSinceEpoch);
  int currentD = daysSinceEpoch(current == null
      ? DateTime.now().millisecondsSinceEpoch
      : current.millisecondsSinceEpoch);

  return currentD >= fromD && currentD <= toD;
}

bool dayMatch(DateTime d1, DateTime d2) {
  return d1.day == d2.day && d1.month == d2.month && d1.year == d2.year;
}

bool dayGreaterOrEqual(DateTime d1, DateTime d2) {
  return daysSinceEpoch(d1.millisecondsSinceEpoch) >=
      daysSinceEpoch(d2.millisecondsSinceEpoch);
}

DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String convertToDDMMYY(DateTime? date) {
  if (date == null) {
    return "?";
  }

  String d = convertToUntisDate(date);
  return "${d.substring(6)}.${d.substring(4, 6)}.${d.substring(2, 4)}";
}

bool dateInRange(
    {required DateTime start,
    required DateTime end,
    required DateTime current}) {
  return current.millisecondsSinceEpoch > start.millisecondsSinceEpoch &&
      current.millisecondsSinceEpoch < end.millisecondsSinceEpoch;
}

String convertToDDMM(DateTime? date) {
  if (date == null) {
    return "?";
  }

  String d = convertToUntisDate(date);
  return "${d.substring(6)}.${d.substring(4, 6)}";
}
