class ValidationService {
 
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    
    if (value.length > 20) {
      return 'Username maksimal 20 karakter';
    }
    
    // Pattern: hanya huruf, angka, dan underscore
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(value)) {
      return 'Username hanya boleh mengandung huruf, angka, dan underscore';
    }
    
    return null; // Valid
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    if (value.length > 50) {
      return 'Password maksimal 50 karakter';
    }
    
    // Harus mengandung minimal 1 huruf
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Password harus mengandung minimal 1 huruf';
    }
    
    // Harus mengandung minimal 1 angka
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung minimal 1 angka';
    }
    
    return null; // Valid
  }

  /// Validasi kombinasi username dan password
  static String? validateCredentials(String? username, String? password) {
    final usernameError = validateUsername(username);
    if (usernameError != null) {
      return usernameError;
    }
    
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      return passwordError;
    }
    
    return null; // Valid
  }

  /// Pengecekan apakah username dan password valid
  static bool isValid(String username, String password) {
    return validateUsername(username) == null && 
           validatePassword(password) == null;
  }
}
