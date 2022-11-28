abstract class BaseParams {
  dynamic toJson();
}

class AbsenceParams extends BaseParams {
  String startDate;
  String endDate;
  bool includeExcused;
  bool includeUnExcused;
  UntisAuth auth;

  AbsenceParams(this.startDate, this.endDate, this.includeExcused,
      this.includeUnExcused, this.auth);

  @override
  dynamic toJson() =>
      {
        "startDate":
      }
}