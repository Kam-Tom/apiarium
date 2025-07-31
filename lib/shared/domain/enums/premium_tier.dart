enum PremiumTier {
  free,
  pro,
  team;

  String get displayName {
    switch (this) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.pro:
        return 'Pro';
      case PremiumTier.team:
        return 'Team';
    }
  }

  bool get isPremium => this != PremiumTier.free;
  bool get canSync => isPremium;
  bool get hasAdvancedFeatures => this == PremiumTier.pro || this == PremiumTier.team;
  bool get hasTeamFeatures => this == PremiumTier.team;
}
