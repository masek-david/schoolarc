

enum NetworkErrorCodes { offline, timeout, serverError }

class NetworkException implements Exception {
  NetworkException(this.code, {this.originalError});

  NetworkErrorCodes code;
  Object? originalError;
}

enum AuthErrorCodes { couldntLogIn, loggedOut, noCanteenId, noUser }

enum ExceptionActions { bakaLogin, stravaLogin }

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

class ApiException implements Exception {
  ApiException(this.apiError);

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
