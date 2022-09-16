enum ClassChangeCode {
  regular("Regulär"),
  irregular("Vertretung"),
  cancelled("Entfall"),
  empty("Unbekannt"),
  unknown("Unbekannt");

  const ClassChangeCode(this.readableName);

  final String readableName;
}

class TimeTableHour {
  //TODO: Continue here
}
