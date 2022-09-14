class FailedToFetchUserdata implements Exception {
  String cause;

  FailedToFetchUserdata(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class UserAlreadyLoggedInException implements Exception {
  String cause;

  UserAlreadyLoggedInException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class WrongCredentialsException implements Exception {
  String cause;

  WrongCredentialsException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class MissingCredentialsException implements Exception {
  String cause;

  MissingCredentialsException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class ApiConnectionError implements Exception {
  String cause;

  ApiConnectionError(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class FailedToFetchNewsException implements Exception {
  String cause;

  FailedToFetchNewsException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class CurrentPhaseplanOutOfRange implements Exception {
  String cause;

  CurrentPhaseplanOutOfRange(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class InsufficientPermissionsException implements Exception {
  String cause;

  InsufficientPermissionsException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class UploadFileNotFoundException implements Exception {
  String cause;

  UploadFileNotFoundException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class UploadFileNotSpecifiedException implements Exception {
  String cause;

  UploadFileNotSpecifiedException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class DownloadFileNotFoundException implements Exception {
  String cause;

  DownloadFileNotFoundException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class NextBlockStartNotInRangeException implements Exception {
  String cause;

  NextBlockStartNotInRangeException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class NextBlockEndNotInRangeException implements Exception {
  String cause;

  NextBlockEndNotInRangeException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class SecurityTokenRequired implements Exception {
  String cause;

  SecurityTokenRequired(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class InvalidSecurityToken implements Exception {
  String cause;

  InvalidSecurityToken(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}
