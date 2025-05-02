class UserService {
    // This is a dummy/placeholder implementation
  String _language = 'polish';
  
  // Getter for the user's language
  String get language => _language;
  
  // Setter to allow changing the language
  set language(String newLanguage) {
    _language = newLanguage;
  }
}