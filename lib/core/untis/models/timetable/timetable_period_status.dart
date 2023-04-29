import 'package:json_annotation/json_annotation.dart';

part 'timetable_period_status.g.dart';

@JsonEnum(alwaysCreate: true, fieldRename: FieldRename.screamingSnake)
enum TimeTablePeriodStatus {
  regular('Regulär'),
  irregular('Veranstaltung o. Vertretung'),
  cancelled('Entfall'),
  exam('Klausur');

  final String displayName;

  const TimeTablePeriodStatus(this.displayName);
}
