class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // ADD THIS PHONE VALIDATOR
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove any non-digit characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // Validate Zambian phone numbers (10 digits starting with 0) or international format
    if (cleanPhone.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    // Zambian phone format: 09XXXXXXXX or +260XXXXXXXX
    if (!RegExp(r'^(\+?260|0)?[1-9]\d{8}$').hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}
