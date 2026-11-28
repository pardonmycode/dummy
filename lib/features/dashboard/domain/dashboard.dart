import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/framework/widget_instance.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

const _uuid = Uuid();

/// A named dashboard configuration.
@freezed
abstract class Dashboard with _$Dashboard {
  const factory Dashboard({
    @Default('') String id,
    required String name,
    @Default([]) List<WidgetInstance> widgets,
  }) = _Dashboard;

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);
}
