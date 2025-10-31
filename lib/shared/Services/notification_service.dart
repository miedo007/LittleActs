/// Lightweight no-op notifications facade for development.
/// Replace with a real implementation (e.g., flutter_local_notifications)
/// once dependencies are added to pubspec and configured.
library;

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  Future<void> init() async {}
  Future<void> cancelAll() async {}

  Future<void> scheduleWeeklyNudge({int hour = 9, int minute = 0}) async {}

  Future<void> scheduleMilestoneReminders(
    List<DateTime> milestoneDates, {
    int daysBefore = 7,
    int hour = 9,
    int minute = 0,
  }) async {}

  Future<void> showNowTest(String title, String body) async {}
}

