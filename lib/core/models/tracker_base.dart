import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracker_base.freezed.dart';
part 'tracker_base.g.dart';

/// Time period for tracking.
enum TimePeriod { day, week, month }

/// A single tracking entry with timestamp.
@freezed
abstract class TrackerEntry with _$TrackerEntry {
  const factory TrackerEntry({
    required num value,
    required DateTime timestamp,
    String? note,
  }) = _TrackerEntry;

  factory TrackerEntry.fromJson(Map<String, dynamic> json) =>
      _$TrackerEntryFromJson(json);
}

/// Shared base model for all tracker widgets (20+ types).
/// Provides goal tracking, streak calculation, entry management, and CSV export.
@freezed
abstract class TrackerBase with _$TrackerBase {
  const factory TrackerBase({
    required num target,
    required String unit,
    @Default(TimePeriod.day) TimePeriod period,
    @Default([]) List<TrackerEntry> entries,
  }) = _TrackerBase;

  factory TrackerBase.fromJson(Map<String, dynamic> json) =>
      _$TrackerBaseFromJson(json);
}

/// Methods that operate on TrackerBase data.
extension TrackerBaseMethods on TrackerBase {
  /// Quick add an entry with current timestamp.
  TrackerBase addEntry(num value, {String? note}) {
    return copyWith(
      entries: [
        ...entries,
        TrackerEntry(value: value, timestamp: DateTime.now(), note: note),
      ],
    );
  }

  /// Calculate current streak (consecutive days with at least one entry).
  int calculateStreak() {
    if (entries.isEmpty) return 0;

    final days = <String, List<TrackerEntry>>{};
    for (final entry in entries) {
      final dayKey = entry.timestamp.toIso8601String().substring(0, 10);
      if (days.containsKey(dayKey)) {
        days[dayKey]!.add(entry);
      } else {
        days[dayKey] = [entry];
      }
    }

    final sortedDays = days.keys.toList()..sort();
    if (sortedDays.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final checkDate = currentDate.subtract(Duration(days: i));
      final dayKey = checkDate.toIso8601String().substring(0, 10);
      if (days.containsKey(dayKey)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate progress toward the goal for the current period.
  double calculateProgress() {
    final now = DateTime.now();
    num periodTotal = 0;

    for (final entry in entries) {
      bool inPeriod = false;
      switch (period) {
        case TimePeriod.day:
          inPeriod = entry.timestamp.year == now.year &&
              entry.timestamp.month == now.month &&
              entry.timestamp.day == now.day;
          break;
        case TimePeriod.week:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          inPeriod = entry.timestamp.isAfter(weekStart) &&
              entry.timestamp.isBefore(now);
          break;
        case TimePeriod.month:
          inPeriod = entry.timestamp.year == now.year &&
              entry.timestamp.month == now.month;
          break;
      }

      if (inPeriod) {
        periodTotal += entry.value;
      }
    }

    if (target == 0) return 0;
    return (periodTotal / target).clamp(0.0, 1.0);
  }

  /// Get the total value for the current period.
  num getPeriodTotal() {
    final now = DateTime.now();
    num periodTotal = 0;

    for (final entry in entries) {
      bool inPeriod = false;
      switch (period) {
        case TimePeriod.day:
          inPeriod = entry.timestamp.year == now.year &&
              entry.timestamp.month == now.month &&
              entry.timestamp.day == now.day;
          break;
        case TimePeriod.week:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          inPeriod = entry.timestamp.isAfter(weekStart) &&
              entry.timestamp.isBefore(now);
          break;
        case TimePeriod.month:
          inPeriod = entry.timestamp.year == now.year &&
              entry.timestamp.month == now.month;
          break;
      }

      if (inPeriod) {
        periodTotal += entry.value;
      }
    }

    return periodTotal;
  }

  /// Export all entries as CSV.
  String exportCSV() {
    final buffer = StringBuffer();
    buffer.writeln('timestamp,value,note');
    for (final entry in entries) {
      final note = entry.note ?? '';
      buffer.writeln(
          '${entry.timestamp.toIso8601String()},${entry.value},"$note"');
    }
    return buffer.toString();
  }
}
