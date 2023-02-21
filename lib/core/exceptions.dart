class UserAlreadyLoggedInException implements Exception {
  String cause;

  UserAlreadyLoggedInException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

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
