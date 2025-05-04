import '../utils/shared_prefs_helper.dart';

class UserService {
  // Getter for the user's language
  String get language => SharedPrefsHelper.getLanguage();
  
  // Setter to allow changing the language
  set language(String newLanguage) {
    SharedPrefsHelper.setLanguage(newLanguage);
  }
}