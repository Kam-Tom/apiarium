import 'dart:convert';

enum UserStatus {
  anonymous,     // Created offline
  cached,        // Synced to backend but still anonymous
  registered,    // Real user account
  guest,         // Temporary session
}

class User {
  final String id;
  final String email;
  final String? name;
  final UserStatus status;
  final String? anonymousPassword;
  final DateTime createdAt;
  final String country;         // Now required
  final bool consentAccepted;   // Now required
  final DateTime? consentAcceptedAt;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.status,
    this.anonymousPassword,
    required this.createdAt,
    required this.country,      // Now required
    required this.consentAccepted, // Now required
    this.consentAcceptedAt,
    this.metadata,
  });

  bool get isAnonymous => status == UserStatus.anonymous || status == UserStatus.cached;
  bool get needsSync => status == UserStatus.anonymous;
  bool get isRegistered => status == UserStatus.registered;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.anonymous,
      ),
      anonymousPassword: json['anonymousPassword'],
      createdAt: DateTime.parse(json['createdAt']),
      country: json['country'],
      consentAccepted: json['consentAccepted'],
      consentAcceptedAt: json['consentAcceptedAt'] != null 
          ? DateTime.parse(json['consentAcceptedAt']) 
          : null,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'status': status.name,
      'anonymousPassword': anonymousPassword,
      'createdAt': createdAt.toIso8601String(),
      'country': country,
      'consentAccepted': consentAccepted,
      'consentAcceptedAt': consentAcceptedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserStatus? status,
    String? anonymousPassword,
    DateTime? createdAt,
    String? country,
    bool? consentAccepted,
    DateTime? consentAcceptedAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      status: status ?? this.status,
      anonymousPassword: anonymousPassword ?? this.anonymousPassword,
      createdAt: createdAt ?? this.createdAt,
      country: country ?? this.country,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      consentAcceptedAt: consentAcceptedAt ?? this.consentAcceptedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper to create anonymous user
  static User createAnonymous({String? country}) {
    final timestamp = DateTime.now();
    final anonymousId = 'anon_${timestamp.millisecondsSinceEpoch}';
    
    return User(
      id: anonymousId,
      email: '$anonymousId@local.app',
      name: 'Anonymous User',
      status: UserStatus.anonymous,
      createdAt: timestamp,
      country: country ?? 'unknown',
      consentAccepted: false,
      metadata: {
        'platform': 'mobile',
        'createdOffline': true,
      },
    );
  }
}
