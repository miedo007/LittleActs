/// Lightweight no-op notifications facade for development.
/// Replace with a real implementation (e.g., flutter_local_notifications)
/// once dependencies are added to pubspec and configured.
library;

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  // In a real impl, request OS permissions and init flutter_local_notifications here.
  Future<void> init() async {}
  Future<void> cancelAll() async {}

  // Wrapper maintained for backward compatibility
  Future<void> scheduleWeeklyNudge({int hour = 9, int minute = 0, String? partnerName}) async {
    await scheduleWeeklyLittleActDrop(partnerName: partnerName ?? 'your partner', hour: hour, minute: minute);
  }

  // 1x per week (e.g., Sunday morning)
  Future<void> scheduleWeeklyLittleActDrop({required String partnerName, int weekday = DateTime.sunday, int hour = 9, int minute = 0}) async {
    final now = DateTime.now();
    final weekday0 = now.weekday % 7; // Sunday=0
    final daysUntil = (weekday - weekday0) % 7;
    final at = DateTime(now.year, now.month, now.day, hour, minute).add(Duration(days: daysUntil));
    final title = 'Your new Little Act 💌';
    final body = 'One small thing to brighten $partnerName\'s day.';
    // TODO: Replace with real scheduling
    // ignore: avoid_print
    print('[Notif] Weekly Drop scheduled at $at | $title — $body');
  }

  // Completion reminder 3 days after act drop
  Future<void> scheduleActCompletionReminder(DateTime dropDate, {int daysAfter = 3, int hour = 9, int minute = 0}) async {
    final at = DateTime(dropDate.year, dropDate.month, dropDate.day, hour, minute).add(Duration(days: daysAfter));
    const title = 'Small act, big effect';
    const body = 'A little takes just a moment and lives forever.';
    // ignore: avoid_print
    print('[Notif] Completion Reminder scheduled at $at | $title — $body');
  }

  Future<void> scheduleMilestoneReminders(
    List<DateTime> milestoneDates, {
    List<String>? names,
    int daysBefore = 3,
    int hour = 9,
    int minute = 0,
  }) async {
    final now = DateTime.now();
    for (var i = 0; i < milestoneDates.length; i++) {
      final date = milestoneDates[i];
      final name = (names != null && i < names.length) ? names[i] : 'A milestone';
      final at = DateTime(date.year, date.month, date.day, hour, minute).subtract(Duration(days: daysBefore));
      final days = date.difference(now).inDays;
      const title = 'Coming up soon 💞';
      final body = '$name is in ${days < 0 ? 0 : days} days, plan a sweet moment?';
      // ignore: avoid_print
      print('[Notif] Milestone Reminder scheduled at $at | $title — $body');
    }
  }

  Future<void> showNowTest(String title, String body) async {
    // ignore: avoid_print
    print('[Notif] Immediate: $title — $body');
  }
}
