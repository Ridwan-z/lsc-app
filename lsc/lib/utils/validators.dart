import './constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return Constants.emailRequired;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return Constants.emailInvalid;
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Constants.passwordRequired;
    }

    if (value.length < 8) {
      return Constants.passwordMinLength;
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return Constants.nameRequired;
    }

    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return Constants.passwordRequired;
    }

    if (value != password) {
      return Constants.passwordNotMatch;
    }

    return null;
  }
}
