enum ExceptionActions {
  bakaLogin,
  stravaLogin,
}

class ServiceException implements Exception {
  ServiceException(this.message, {this.action});

  String? message;
  ExceptionActions? action;

  @override
  String toString() {
    return message ?? '';
  }
}
