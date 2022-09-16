enum Weekday {
  monday("Montag", "Mo."),
  tuesday("Dienstag", "Di."),
  wednesday("Mittwoch", "Mi."),
  thursday("Donnerstag", "Do."),
  friday("Freitag", "Fr."),
  saturday("Samstag", "Sa."),
  sunday("Sonntag", "So.");

  const Weekday(this.name, this.shortName);

  final String name;
  final String shortName;
}
