class FailedToFetchUserdata implements Exception {
  String cause;

  FailedToFetchUserdata(this.cause);

  @override
  String toString() {
    return cause;
  }
}

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

class FailedToFetchNewsException implements Exception {
  String cause;

  FailedToFetchNewsException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class InsufficientPermissionsException implements Exception {
  String cause;

  InsufficientPermissionsException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class UploadFileNotFoundException implements Exception {
  String cause;

  UploadFileNotFoundException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class UploadFileNotSpecifiedException implements Exception {
  String cause;

  UploadFileNotSpecifiedException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class DownloadFileNotFoundException implements Exception {
  String cause;

  DownloadFileNotFoundException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class NextBlockStartNotInRangeException implements Exception {
  String cause;

  NextBlockStartNotInRangeException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class NextBlockEndNotInRangeException implements Exception {
  String cause;

  NextBlockEndNotInRangeException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class SecurityTokenRequired implements Exception {
  String cause;

  SecurityTokenRequired(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class InvalidSecurityToken implements Exception {
  String cause;

  InvalidSecurityToken(this.cause);

  @override
  String toString() {
    return cause;
  }
}
