// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PartyEvent _$PartyEventFromJson(Map<String, dynamic> json) => _PartyEvent(
  name: json['name'] as String,
  venue: json['venue'] as String,
  time: json['time'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  genre: json['genre'] as String?,
);

Map<String, dynamic> _$PartyEventToJson(_PartyEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'venue': instance.venue,
      'time': instance.time,
      'lat': instance.lat,
      'lng': instance.lng,
      'genre': instance.genre,
    };

_PartiesData _$PartiesDataFromJson(Map<String, dynamic> json) => _PartiesData(
  events: (json['events'] as List<dynamic>)
      .map((e) => PartyEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PartiesDataToJson(_PartiesData instance) =>
    <String, dynamic>{'events': instance.events};
