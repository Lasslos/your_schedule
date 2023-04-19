class WrongCredentialsException implements Exception {
  String cause;

  WrongCredentialsException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class MissingCredentialsException implements Exception {
  String cause;

  MissingCredentialsException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class ApiConnectionError implements Exception {
  String cause;

  ApiConnectionError(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class InvalidSchoolNameException implements Exception {
  String cause;

  InvalidSchoolNameException(this.cause);

  @override
  String toString() {
    return cause;
  }
}
