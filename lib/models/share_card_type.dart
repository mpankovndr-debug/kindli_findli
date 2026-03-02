enum ShareCardType {
  intention, // Free tier
  milestone, // Premium only
}

enum MilestoneVariant {
  showingUp, // "X weeks of showing up — in your own way"
  area, // "You keep coming back to [area]"
  identity, // "[Habit] is becoming your thing"
}

/// Flat selection passed from picker → card preview screen.
enum ShareCardSelection {
  weeklyCheckin,
  milestoneShowingUp,
  milestoneArea,
  milestoneIdentity,
}

extension ShareCardSelectionX on ShareCardSelection {
  bool get isMilestone => this != ShareCardSelection.weeklyCheckin;

  MilestoneVariant? get milestoneVariant => switch (this) {
    ShareCardSelection.milestoneShowingUp => MilestoneVariant.showingUp,
    ShareCardSelection.milestoneArea => MilestoneVariant.area,
    ShareCardSelection.milestoneIdentity => MilestoneVariant.identity,
    ShareCardSelection.weeklyCheckin => null,
  };
}
