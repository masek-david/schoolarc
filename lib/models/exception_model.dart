enum NetworkErrorCodes { offline, timeout, serverError }

class NetworkException implements Exception {
  NetworkException(this.code, {this.originalError});

  NetworkErrorCodes code;
  Object? originalError;
}

enum AuthErrorCodes {
  /// Use when the user isnt logged in -> should entry their login info
  loggedOut,
  noCanteenId,
  noUser,
  repeatedPasswordNotSame,
  newOldPasswordSame,
}

enum ExceptionActions { bakaLogin, stravaLogin, cloudsyncLogin }

class AuthException implements Exception {
  AuthException(this.code, {this.exceptionAction});

  AuthErrorCodes code;
  ExceptionActions? exceptionAction;
}

enum ValidationErrorCodes {
  emptyField,
  invalidCanteenNumber,
  invalidCanteenNumberLength,
}

class ValidationException implements Exception {
  ValidationException(this.code);

  final ValidationErrorCodes code;
}

enum GroupErrorCodes {
  notMemberOfAnyGroup,
  waitingForApproval,
  removedFromGroup,
  leaveOldGroup,
  cantLeaveYourGroup,
  cantChangeName,
}

class GroupException implements Exception {
  GroupException(this.code);

  final GroupErrorCodes code;
}

enum DisabledErrorCodes { bakalariDisabled, mealsDisabled }

class DisabledException implements Exception {
  DisabledException(this.code);

  final DisabledErrorCodes code;
}

enum ApiErrorCodes { cantLogIn, passwordCantBeChanged, cantDeleteData }

class ApiException implements Exception {
  ApiException(this.apiError, {this.code});

  final ApiErrorCodes? code;
  final String apiError;
}

class StringException implements Exception {
  StringException(this.message);

  String? message;
  @override
  String toString() {
    return message ?? '';
  }
}
