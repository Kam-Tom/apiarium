class Country {
  final String code;
  final String name;
  final String flag;
  final String currency;
  final String language;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
    required this.currency,
    required this.language,
  });
}

class Countries {
  static const List<Country> list = [
    Country(code: 'US', name: 'United States', flag: '🇺🇸', currency: 'USD', language: 'en'),
    Country(code: 'PL', name: 'Poland', flag: '🇵🇱', currency: 'PLN', language: 'pl'),
    Country(code: 'GB', name: 'United Kingdom', flag: '🇬🇧', currency: 'GBP', language: 'en'),
    Country(code: 'DE', name: 'Germany', flag: '🇩🇪', currency: 'EUR', language: 'de'),
    Country(code: 'FR', name: 'France', flag: '🇫🇷', currency: 'EUR', language: 'fr'),
    Country(code: 'ES', name: 'Spain', flag: '🇪🇸', currency: 'EUR', language: 'es'),
    Country(code: 'IT', name: 'Italy', flag: '🇮🇹', currency: 'EUR', language: 'it'),
    Country(code: 'NL', name: 'Netherlands', flag: '🇳🇱', currency: 'EUR', language: 'nl'),
    Country(code: 'BE', name: 'Belgium', flag: '🇧🇪', currency: 'EUR', language: 'nl'),
    Country(code: 'AT', name: 'Austria', flag: '🇦🇹', currency: 'EUR', language: 'de'),
    Country(code: 'CH', name: 'Switzerland', flag: '🇨🇭', currency: 'CHF', language: 'de'),
    Country(code: 'SE', name: 'Sweden', flag: '🇸🇪', currency: 'SEK', language: 'sv'),
    Country(code: 'NO', name: 'Norway', flag: '🇳🇴', currency: 'NOK', language: 'no'),
    Country(code: 'DK', name: 'Denmark', flag: '🇩🇰', currency: 'DKK', language: 'da'),
    Country(code: 'FI', name: 'Finland', flag: '🇫🇮', currency: 'EUR', language: 'fi'),
    Country(code: 'CZ', name: 'Czech Republic', flag: '🇨🇿', currency: 'CZK', language: 'cs'),
    Country(code: 'SK', name: 'Slovakia', flag: '🇸🇰', currency: 'EUR', language: 'sk'),
    Country(code: 'HU', name: 'Hungary', flag: '🇭🇺', currency: 'HUF', language: 'hu'),
    Country(code: 'RO', name: 'Romania', flag: '🇷🇴', currency: 'RON', language: 'ro'),
    Country(code: 'BG', name: 'Bulgaria', flag: '🇧🇬', currency: 'BGN', language: 'bg'),
    Country(code: 'HR', name: 'Croatia', flag: '🇭🇷', currency: 'EUR', language: 'hr'),
    Country(code: 'SI', name: 'Slovenia', flag: '🇸🇮', currency: 'EUR', language: 'sl'),
    Country(code: 'EE', name: 'Estonia', flag: '🇪🇪', currency: 'EUR', language: 'et'),
    Country(code: 'LV', name: 'Latvia', flag: '🇱🇻', currency: 'EUR', language: 'lv'),
    Country(code: 'LT', name: 'Lithuania', flag: '🇱🇹', currency: 'EUR', language: 'lt'),
    Country(code: 'CA', name: 'Canada', flag: '🇨🇦', currency: 'CAD', language: 'en'),
    Country(code: 'AU', name: 'Australia', flag: '🇦🇺', currency: 'AUD', language: 'en'),
    Country(code: 'NZ', name: 'New Zealand', flag: '🇳🇿', currency: 'NZD', language: 'en'),
    Country(code: 'IE', name: 'Ireland', flag: '🇮🇪', currency: 'EUR', language: 'en'),
    Country(code: 'GR', name: 'Greece', flag: '🇬🇷', currency: 'EUR', language: 'el'),
    Country(code: 'PT', name: 'Portugal', flag: '🇵🇹', currency: 'EUR', language: 'pt'),
    Country(code: 'UA', name: 'Ukraine', flag: '🇺🇦', currency: 'UAH', language: 'uk'),
  ];

  // Default fallback country
  static const Country _defaultCountry = Country(
    code: 'US', 
    name: 'United States', 
    flag: '🇺🇸', 
    currency: 'USD', 
    language: 'en'
  );

  // Supported app languages
  static const List<String> supportedLanguages = ['en', 'pl'];

  // Main helper methods - clean and simple
  static Country byCode(String code) => 
    list.where((c) => c.code == code.toUpperCase()).firstOrNull ?? _defaultCountry;

  static Country byLanguage(String language) => 
    list.where((c) => c.language == language.toLowerCase()).firstOrNull ?? _defaultCountry;

  // Convenience getters using the main helpers
  static String getCountryName(String code) => byCode(code).name;
  static String getCountryFlag(String code) => byCode(code).flag;
  static String getCountryCurrency(String code) => byCode(code).currency;
  static String getCountryLanguage(String code) => byCode(code).language;

  // Better method for getting default country from locale
  static Country getDefaultCountryFromLocale(String locale) {
    final language = locale.toLowerCase().split('_').first;
    final country = list.where((c) => c.language == language).firstOrNull;
    return country ?? _defaultCountry;
  }

  // Better method for getting language with app support fallback
  static String getDefaultLanguageFromCountry(String countryCode) {
    final country = byCode(countryCode);
    return supportedLanguages.contains(country.language) ? country.language : 'en';
  }

  static List<String> getSupportedCurrencies() {
    return list.map((c) => c.currency).toSet().toList()..sort();
  }

  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'PLN': return 'zł';
      case 'CHF': return 'CHF';
      case 'SEK':
      case 'NOK':
      case 'DKK': return 'kr';
      case 'CZK': return 'Kč';
      case 'HUF': return 'Ft';
      case 'RON': return 'lei';
      case 'BGN': return 'лв';
      case 'CAD': return 'C\$';
      case 'AUD': return 'A\$';
      case 'NZD': return 'NZ\$';
      case 'UAH': return '₴';
      default: return currency;
    }
  }
}
