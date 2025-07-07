import 'package:school_manager/l10n/my_localization.dart';

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
  BakaLoginException({this.message});

  String? message;

  @override
  String toString() {
    return message ?? getLocalization().pleaseLogIn;
  }
}
