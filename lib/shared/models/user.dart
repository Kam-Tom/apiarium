import 'dart:convert';

class User {
  final String id;
  final bool termsAccepted;
  final DateTime? termsAcceptedAt;
  final String? country;
  final DateTime updatedAt;
  final bool isAnonymous;
  final String? displayName;
  final String? photoURL;

  User({
    required this.id,
    required this.termsAccepted,
    this.termsAcceptedAt,
    this.country,
    required this.updatedAt,
    required this.isAnonymous,
    this.displayName,
    this.photoURL,
  });

  String get name => displayName ?? 'User';

  User copyWith({
    bool? termsAccepted,
    DateTime? termsAcceptedAt,
    String? country,
    DateTime? updatedAt,
    bool? isAnonymous,
    String? displayName,
    String? photoURL,
  }) {
    return User(
      id: id,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      country: country ?? this.country,
      updatedAt: updatedAt ?? DateTime.now(),
      isAnonymous: isAnonymous ?? this.isAnonymous,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'termsAccepted': termsAccepted,
    'termsAcceptedAt': termsAcceptedAt?.toIso8601String(),
    'country': country,
    'updatedAt': updatedAt.toIso8601String(),
    'isAnonymous': isAnonymous,
    'displayName': displayName,
    'photoURL': photoURL,
  };

  factory User.fromJson(Map<String, dynamic> json, [String? id]) => User(
    id: id ?? json['id'],
    termsAccepted: json['termsAccepted'] ?? false,
    termsAcceptedAt: json['termsAcceptedAt'] != null 
        ? DateTime.parse(json['termsAcceptedAt']) 
        : null,
    country: json['country'],
    updatedAt: DateTime.parse(json['updatedAt']),
    isAnonymous: json['isAnonymous'] ?? false,
    displayName: json['displayName'],
    photoURL: json['photoURL'],
  );

  String toJsonString() => jsonEncode(toJson());
  
  factory User.fromJsonString(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return User.fromJson(data);
  }

  @override
  String toString() => 'User(id: $id, name: $name, isAnonymous: $isAnonymous, country: $country, photoURL: $photoURL)';
}