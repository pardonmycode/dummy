import 'package:freezed_annotation/freezed_annotation.dart';

part 'party_event.freezed.dart';
part 'party_event.g.dart';

/// Event on the parties map.
@freezed
abstract class PartyEvent with _$PartyEvent {
  const factory PartyEvent({
    required String name,
    required String venue,
    required String time,
    required double lat,
    required double lng,
    String? genre,
  }) = _PartyEvent;

  factory PartyEvent.fromJson(Map<String, dynamic> json) =>
      _$PartyEventFromJson(json);
}

/// Typed data model for parties widget.
@freezed
abstract class PartiesData with _$PartiesData {
  const factory PartiesData({
    required List<PartyEvent> events,
  }) = _PartiesData;

  factory PartiesData.fromJson(Map<String, dynamic> json) =>
      _$PartiesDataFromJson(json);
}
