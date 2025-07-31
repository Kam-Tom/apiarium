import 'dart:convert';
import 'package:apiarium/shared/shared.dart';

import '../enums/premium_tier.dart';
import 'base_model.dart';

class User extends BaseModel {
  final bool termsAccepted;
  final DateTime? termsAcceptedAt;
  final String country;
  final String currency;
  final String language;
  final bool isAnonymous;
  final String? displayName;
  final String? photoURL;
  final PremiumTier premiumTier;
  final DateTime? premiumExpiresAt;

  User({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.termsAccepted,
    this.termsAcceptedAt,
    required this.country,
    String? currency,
    String? language,
    required this.isAnonymous,
    this.displayName,
    this.photoURL,
    this.premiumTier = PremiumTier.free,
    this.premiumExpiresAt,
    SyncStatus syncStatus = SyncStatus.pending,
    DateTime? lastSyncedAt,
    bool deleted = false,
    int serverVersion = 0,
  }) : currency = currency ?? Countries.getCountryCurrency(country),
       language = language ?? Countries.getDefaultLanguageFromCountry(country),
       super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: syncStatus,
          lastSyncedAt: lastSyncedAt,
          deleted: deleted,
          serverVersion: serverVersion,
        );

  String get name => displayName ?? 'User';
  bool get isPremium => premiumTier.isPremium && 
      (premiumExpiresAt?.isAfter(DateTime.now()) ?? premiumTier == PremiumTier.pro);
  String get currencySymbol => Countries.getCurrencySymbol(currency);

  User copyWith({
    bool? termsAccepted,
    DateTime? termsAcceptedAt,
    String? country,
    String? currency,
    String? language,
    DateTime? updatedAt,
    bool? isAnonymous,
    String? displayName,
    String? photoURL,
    PremiumTier? premiumTier,
    DateTime? premiumExpiresAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    bool? deleted,
    int? serverVersion,
  }) {
    final newCountry = country ?? this.country;
    return User(
      id: id,
      createdAt: createdAt,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      country: newCountry,
      currency: currency ?? (country != null ? Countries.getCountryCurrency(newCountry) : this.currency),
      language: language ?? (country != null ? Countries.getDefaultLanguageFromCountry(newCountry) : this.language),
      updatedAt: updatedAt ?? DateTime.now(),
      isAnonymous: isAnonymous ?? this.isAnonymous,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      premiumTier: premiumTier ?? this.premiumTier,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deleted: deleted ?? this.deleted,
      serverVersion: serverVersion ?? this.serverVersion,
    );
  }

  Map<String, dynamic> toJson() => {
    ...baseSyncFields,
    'termsAccepted': termsAccepted,
    'termsAcceptedAt': termsAcceptedAt?.toIso8601String(),
    'country': country,
    'currency': currency,
    'language': language,
    'isAnonymous': isAnonymous,
    'displayName': displayName,
    'photoURL': photoURL,
    'premiumTier': premiumTier.name,
    'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json, [String? id]) {
    final country = json['country'] ?? 'US';
    return User(
      id: id ?? json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      termsAccepted: json['termsAccepted'] ?? false,
      termsAcceptedAt: json['termsAcceptedAt'] != null 
          ? DateTime.parse(json['termsAcceptedAt']) 
          : null,
      country: country,
      currency: json['currency'] ?? Countries.getCountryCurrency(country),
      language: json['language'] ?? Countries.getDefaultLanguageFromCountry(country),
      isAnonymous: json['isAnonymous'] ?? false,
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      premiumTier: PremiumTier.values.firstWhere(
        (tier) => tier.name == json['premiumTier'],
        orElse: () => PremiumTier.free,
      ),
      premiumExpiresAt: json['premiumExpiresAt'] != null 
          ? DateTime.parse(json['premiumExpiresAt']) 
          : null,
      syncStatus: SyncStatus.values.firstWhere(
        (status) => status.name == json['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      lastSyncedAt: json['lastSyncedAt'] != null 
          ? DateTime.parse(json['lastSyncedAt']) 
          : null,
      deleted: json['deleted'] ?? false,
      serverVersion: json['serverVersion'] ?? 0,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  
  factory User.fromJsonString(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return User.fromJson(data);
  }

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    termsAccepted,
    termsAcceptedAt,
    country,
    currency,
    language,
    isAnonymous,
    displayName,
    photoURL,
    premiumTier,
    premiumExpiresAt,
  ];

  @override
  String toString() => 'User(id: $id, name: $name, isAnonymous: $isAnonymous, country: $country, currency: $currency, language: $language, premiumTier: ${premiumTier.name})';
}