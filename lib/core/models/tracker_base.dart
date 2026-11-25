
/// Time period for tracking.
enum TimePeriod { day, week, month }

/// A single tracking entry with timestamp.
class TrackerEntry {
  final DateTime timestamp;
  final num value;
  final String? note;

  TrackerEntry({
    required this.value,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      if (note != null) 'note': note,
    };
  }

  factory TrackerEntry.fromJson(Map<String, dynamic> json) {
    return TrackerEntry(
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
    );
  }
}

/// Shared base model for all tracker widgets (20+ types).
/// Provides goal tracking, streak calculation, entry management, and CSV export.
class TrackerBase {
  /// Tracking target/goal value.
  num target;

  /// Unit of measurement (e.g., 'steps', 'g', 'ml').
  String unit;

  /// Time period for the goal.
  TimePeriod period;

  /// All tracking entries.
  final List<TrackerEntry> entries = [];

  TrackerBase({
    required this.target,
    required this.unit,
    this.period = TimePeriod.day,
    List<TrackerEntry>? entries,
  }) {
    if (entries != null) {
      this.entries.addAll(entries);
    }
  }

  /// Quick add an entry with current timestamp.
  void addEntry(num value, {String? note}) {
    entries.add(TrackerEntry(value: value, timestamp: DateTime.now(), note: note));
  }

  /// Edit an existing entry by index.
  void editEntry(int index, num value, {String? note}) {
    if (index < 0 || index >= entries.length) return;
    entries[index] = TrackerEntry(
      value: value,
      timestamp: entries[index].timestamp,
      note: note ?? entries[index].note,
    );
  }

  /// Delete an entry by index.
  void deleteEntry(int index) {
    if (index < 0 || index >= entries.length) return;
    entries.removeAt(index);
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

    // Walk back from today
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
      buffer.writeln('${entry.timestamp.toIso8601String()},${entry.value},"$note"');
    }
    return buffer.toString();
  }

  /// Serialize to JSON.
  Map<String, dynamic> toJson() {
    return {
      'target': target,
      'unit': unit,
      'period': period.name,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  /// Deserialize from JSON.
  factory TrackerBase.fromJson(Map<String, dynamic> json) {
    final entries = (json['entries'] as List?)
        ?.map((e) => TrackerEntry.fromJson(e))
        .toList();
    return TrackerBase(
      target: json['target'],
      unit: json['unit'],
      period: TimePeriod.values.firstWhere(
        (p) => p.name == json['period'],
        orElse: () => TimePeriod.day,
      ),
      entries: entries,
    );
  }
}
