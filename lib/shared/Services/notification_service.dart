/// Notifications service using flutter_local_notifications with timezone support.
library;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'nudges_default',
    'Nudges',
    description: 'Reminders for weekly acts and milestones',
    importance: Importance.high,
  );

  bool _initialized = false;
  static bool _tzReady = false;

  Future<void> _ensureTz() async {
    if (_tzReady) return;
    try {
      tz.initializeTimeZones();
    } catch (_) {
      // ignore duplicate init across hot restarts
    }
    _tzReady = true;
  }

  Future<void> init() async {
    if (_initialized) return;

    // Defer timezone init until first schedule call to reduce startup cost.

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
      macOS: null,
    );

    await _plugin.initialize(initializationSettings);

    // Create default channel on Android
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(_defaultChannel);
    }

    _initialized = true;
  }

  // Request OS notification permissions explicitly when user opts in
  Future<void> requestPermissions() async {
    await init();
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Wrapper maintained for backward compatibility
  Future<void> scheduleWeeklyNudge({
    int hour = 9,
    int minute = 0,
    String? partnerName,
  }) async {
    await scheduleWeeklyLittleActDrop(
      partnerName: partnerName ?? 'your partner',
      hour: hour,
      minute: minute,
    );
  }

  // 1x per week (default: Sunday morning)
  Future<void> scheduleWeeklyLittleActDrop({
    required String partnerName,
    int weekday = DateTime.sunday, // 7-based (Mon=1..Sun=7)
    int hour = 9,
    int minute = 0,
  }) async {
    await init();
    await _ensureTz();
    final id = _stableId('weekly_drop');
    final title = 'Your new Little Act';
    final body = 'One small thing to brighten $partnerName\'s day.';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final next = _nextInstanceOfWeekdayTime(weekday, hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      next,
      details,
      // Avoid exact alarms to prevent permission errors on Android 13+
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Completion reminder a few days after an act is dropped
  Future<void> scheduleActCompletionReminder(
    DateTime dropDate, {
    int daysAfter = 3,
    int hour = 9,
    int minute = 0,
  }) async {
    await init();
    await _ensureTz();
    final when = DateTime(dropDate.year, dropDate.month, dropDate.day, hour,
            minute)
        .add(Duration(days: daysAfter));
    const title = 'Small act, big effect';
    const body = 'A little takes just a moment and lives forever.';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final tzWhen = tz.TZDateTime.from(when, tz.local);

    await _plugin.zonedSchedule(
      _stableId('act_complete_${when.millisecondsSinceEpoch}'),
      title,
      body,
      tzWhen,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleMilestoneReminders(
    List<DateTime> milestoneDates, {
    List<String>? names,
    int daysBefore = 3,
    int hour = 9,
    int minute = 0,
  }) async {
    await init();
    await _ensureTz();
    final now = DateTime.now();
    for (var i = 0; i < milestoneDates.length; i++) {
      final date = milestoneDates[i];
      final name = (names != null && i < names.length)
          ? names[i]
          : 'A milestone';
      final at = DateTime(date.year, date.month, date.day, hour, minute)
          .subtract(Duration(days: daysBefore));
      final days = date.difference(now).inDays;
      const title = 'Coming up soon';
      final body =
          '$name is in ${days < 0 ? 0 : days} days, plan a sweet moment?';

      final tzAt = tz.TZDateTime.from(at, tz.local);

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        _stableId('milestone_${date.millisecondsSinceEpoch}_$i'),
        title,
        body,
        tzAt,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      // Yield to event loop every 8 items to avoid jank on large lists
      if ((i + 1) % 8 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }
  }

  Future<void> showNowTest(String title, String body) async {
    await init();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(_randomId(), title, body, details);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Notif] Immediate shown: $title — $body');
    }
  }

  int _randomId() => Random().nextInt(1 << 31);
  int _stableId(String key) => key.hashCode & 0x7fffffff;

  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    // DateTime.weekday uses Mon=1..Sun=7
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // advance until correct weekday and time in the future
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
      scheduled = tz.TZDateTime(
        tz.local,
        scheduled.year,
        scheduled.month,
        scheduled.day,
        hour,
        minute,
      );
    }
    return scheduled;
  }
}
