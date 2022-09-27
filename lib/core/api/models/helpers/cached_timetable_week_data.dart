import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_time_span.dart';

///[CachedTimeTableWeekData] contains persistent information and is stored in the cache.
///This includes:
/// * Period Start and End
/// * Start of the week
/// * End of the week
/// * Index of the current week
@immutable
class CachedTimeTableWeekData {
  final DateTime startDate;
  final DateTime endDate;
  final int relativeToCurrentWeek;

  final TimeTableTimeSpan cachedWeekData;

  const CachedTimeTableWeekData(this.startDate, this.endDate,
      this.relativeToCurrentWeek, this.cachedWeekData);
}
