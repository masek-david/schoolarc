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

class BakaLoginException implements Exception {
  BakaLoginException({this.message = 'Please log in'});

  String? message;

  @override
  String toString() {
    return message ?? '';
  }
}
