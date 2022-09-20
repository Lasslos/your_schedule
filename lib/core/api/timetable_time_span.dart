//TimeTable Frame, Range, Manager
//New Names: CachedTimeTableData, TimeTableTimeSpan, TimeTableManager

import 'package:your_schedule/core/api/cached_timetable_week_data.dart';
import 'package:your_schedule/core/api/models/timetable_day.dart';
import 'package:your_schedule/core/api/rpc_response.dart';

class TimeTableTimeSpan {
  final DateTime startDate;
  final DateTime endDate;

  final List<TimeTableDay> days = [];

  bool get isEmpty => days.isEmpty;

  final CachedTimetableWeekData weekData;

  TimeTableTimeSpan(
      this.startDate, this.endDate, this.weekData, RPCResponse response) {
    if (!response.isOK) {
      if (response.errorCode == -7004) {
        //"no allowed date"
        //create empty table
        for (int i = 0; i < endDate.difference(startDate).inDays; i++) {
          days.add(TimeTableDay(startDate.add(Duration(days: i)), this));
        }
        return;
      } else {
        throw Exception(
            "Error while loading timetable: ${response.statusMessage} (${response.errorCode})");
      }
    }

    DateTime firstDateInResponse;
    try {
      for (Map<String, dynamic> entry in response.payload) {
        //TODO: Continue here

      }
    } catch (e) {
      throw Exception(
          "Error while loading timetable. Response JSON might be malformed. \n ${e.toString()} \n ${response.payload}");
    }
  }
}
