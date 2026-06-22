enum SubscriptionPlan {
  yearlyRegular,
  yearlyIntro,
  yearlyStandard,
}

extension SubscriptionPlanApi on SubscriptionPlan {
  /// Backend checkout plan key sent to `/subscription/polar/checkout`.
  String get apiValue {
    switch (this) {
      case SubscriptionPlan.yearlyRegular:
      case SubscriptionPlan.yearlyIntro:
        return 'YEARLY_REGULAR';
      case SubscriptionPlan.yearlyStandard:
        return 'YEARLY_STANDARD';
    }
  }
}
