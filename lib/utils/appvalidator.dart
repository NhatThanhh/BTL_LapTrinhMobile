class AppValidator {
  String? validateUserName(value) {
    if (value!.isEmpty) {
      return 'Nhập tài khoản';
    }
    return null;
  }

  String? validateEmail(value) {
    if (value!.isEmpty) {
      return 'Nhập email';
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email không hợp lệ ';
    }
    return null;
  }

  String? validatePhoneNumber(value) {
    if (value!.isEmpty) {
      return 'Nhập số điện thoại';
    }
    if (value.length != 10) {
      return 'Số điện thoại không hợp lệ';
    }
  }

  String? validatePassword(value) {
    if (value!.isEmpty) {
      return 'Nhập mật khẩu';
    }
    return null;
  }

  String? isEmptyCheck(value) {
    if (value!.isEmpty) {
      return 'Điền danh mục';
    }
    return null;
  }

  String? validateField(String field, String? value) {
    switch (field) {
      case 'username':
        return validateUserName(value);
      case 'email':
        return validateEmail(value);
      case 'phone':
        return validatePhoneNumber(value);
      case 'password':
        return validatePassword(value);
      default:
        return isEmptyCheck(value);
    }
  }
}
