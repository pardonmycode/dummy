// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'party_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PartyEvent {

 String get name; String get venue; String get time; double get lat; double get lng; String? get genre;
/// Create a copy of PartyEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyEventCopyWith<PartyEvent> get copyWith => _$PartyEventCopyWithImpl<PartyEvent>(this as PartyEvent, _$identity);

  /// Serializes this PartyEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PartyEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartyEvent&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.venue, _this.venue) || other.venue == _this.venue)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng)&&(identical(other.genre, _this.genre) || other.genre == _this.genre));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PartyEvent;
  return Object.hash(runtimeType,_this.name,_this.venue,_this.time,_this.lat,_this.lng,_this.genre);
}

@override
String toString() {
  final _this = this as PartyEvent;
  return 'PartyEvent(name: ${_this.name}, venue: ${_this.venue}, time: ${_this.time}, lat: ${_this.lat}, lng: ${_this.lng}, genre: ${_this.genre})';
}


}

/// @nodoc
abstract mixin class $PartyEventCopyWith<$Res>  {
  factory $PartyEventCopyWith(PartyEvent value, $Res Function(PartyEvent) _then) = _$PartyEventCopyWithImpl;
@useResult
$Res call({
 String name, String venue, String time, double lat, double lng, String? genre
});




}
/// @nodoc
class _$PartyEventCopyWithImpl<$Res>
    implements $PartyEventCopyWith<$Res> {
  _$PartyEventCopyWithImpl(this._self, this._then);

  final PartyEvent _self;
  final $Res Function(PartyEvent) _then;

/// Create a copy of PartyEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? venue = null,Object? time = null,Object? lat = null,Object? lng = null,Object? genre = freezed,}) {
  return _then(PartyEvent(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PartyEvent].
extension PartyEventPatterns on PartyEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartyEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartyEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartyEvent value)  $default,){
final _that = this;
switch (_that) {
case _PartyEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartyEvent value)?  $default,){
final _that = this;
switch (_that) {
case _PartyEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String venue,  String time,  double lat,  double lng,  String? genre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartyEvent() when $default != null:
return $default(_that.name,_that.venue,_that.time,_that.lat,_that.lng,_that.genre);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String venue,  String time,  double lat,  double lng,  String? genre)  $default,) {final _that = this;
switch (_that) {
case _PartyEvent():
return $default(_that.name,_that.venue,_that.time,_that.lat,_that.lng,_that.genre);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String venue,  String time,  double lat,  double lng,  String? genre)?  $default,) {final _that = this;
switch (_that) {
case _PartyEvent() when $default != null:
return $default(_that.name,_that.venue,_that.time,_that.lat,_that.lng,_that.genre);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartyEvent implements PartyEvent {
  const _PartyEvent({required this.name, required this.venue, required this.time, required this.lat, required this.lng, this.genre});
  factory _PartyEvent.fromJson(Map<String, dynamic> json) => _$PartyEventFromJson(json);

@override final  String name;
@override final  String venue;
@override final  String time;
@override final  double lat;
@override final  double lng;
@override final  String? genre;

/// Create a copy of PartyEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyEventCopyWith<_PartyEvent> get copyWith => __$PartyEventCopyWithImpl<_PartyEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartyEvent&&(identical(other.name, name) || other.name == name)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.time, time) || other.time == time)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.genre, genre) || other.genre == genre));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,venue,time,lat,lng,genre);
}

@override
String toString() {
    return 'PartyEvent(name: $name, venue: $venue, time: $time, lat: $lat, lng: $lng, genre: $genre)';
}


}

/// @nodoc
abstract mixin class _$PartyEventCopyWith<$Res> implements $PartyEventCopyWith<$Res> {
  factory _$PartyEventCopyWith(_PartyEvent value, $Res Function(_PartyEvent) _then) = __$PartyEventCopyWithImpl;
@override @useResult
$Res call({
 String name, String venue, String time, double lat, double lng, String? genre
});




}
/// @nodoc
class __$PartyEventCopyWithImpl<$Res>
    implements _$PartyEventCopyWith<$Res> {
  __$PartyEventCopyWithImpl(this._self, this._then);

  final _PartyEvent _self;
  final $Res Function(_PartyEvent) _then;

/// Create a copy of PartyEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? venue = null,Object? time = null,Object? lat = null,Object? lng = null,Object? genre = freezed,}) {
  return _then(_PartyEvent(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PartiesData {

 List<PartyEvent> get events;
/// Create a copy of PartiesData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartiesDataCopyWith<PartiesData> get copyWith => _$PartiesDataCopyWithImpl<PartiesData>(this as PartiesData, _$identity);

  /// Serializes this PartiesData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PartiesData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartiesData&&const DeepCollectionEquality().equals(other.events, _this.events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PartiesData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.events));
}

@override
String toString() {
  final _this = this as PartiesData;
  return 'PartiesData(events: ${_this.events})';
}


}

/// @nodoc
abstract mixin class $PartiesDataCopyWith<$Res>  {
  factory $PartiesDataCopyWith(PartiesData value, $Res Function(PartiesData) _then) = _$PartiesDataCopyWithImpl;
@useResult
$Res call({
 List<PartyEvent> events
});




}
/// @nodoc
class _$PartiesDataCopyWithImpl<$Res>
    implements $PartiesDataCopyWith<$Res> {
  _$PartiesDataCopyWithImpl(this._self, this._then);

  final PartiesData _self;
  final $Res Function(PartiesData) _then;

/// Create a copy of PartiesData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? events = null,}) {
  return _then(PartiesData(
events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<PartyEvent>,
  ));
}

}


/// Adds pattern-matching-related methods to [PartiesData].
extension PartiesDataPatterns on PartiesData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartiesData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartiesData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartiesData value)  $default,){
final _that = this;
switch (_that) {
case _PartiesData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartiesData value)?  $default,){
final _that = this;
switch (_that) {
case _PartiesData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PartyEvent> events)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartiesData() when $default != null:
return $default(_that.events);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PartyEvent> events)  $default,) {final _that = this;
switch (_that) {
case _PartiesData():
return $default(_that.events);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PartyEvent> events)?  $default,) {final _that = this;
switch (_that) {
case _PartiesData() when $default != null:
return $default(_that.events);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartiesData implements PartiesData {
  const _PartiesData({required  List<PartyEvent> events}): _events = events;
  factory _PartiesData.fromJson(Map<String, dynamic> json) => _$PartiesDataFromJson(json);

 final  List<PartyEvent> _events;
@override List<PartyEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}


/// Create a copy of PartiesData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartiesDataCopyWith<_PartiesData> get copyWith => __$PartiesDataCopyWithImpl<_PartiesData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartiesDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartiesData&&const DeepCollectionEquality().equals(other.events, _events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_events));
}

@override
String toString() {
    return 'PartiesData(events: $events)';
}


}

/// @nodoc
abstract mixin class _$PartiesDataCopyWith<$Res> implements $PartiesDataCopyWith<$Res> {
  factory _$PartiesDataCopyWith(_PartiesData value, $Res Function(_PartiesData) _then) = __$PartiesDataCopyWithImpl;
@override @useResult
$Res call({
 List<PartyEvent> events
});




}
/// @nodoc
class __$PartiesDataCopyWithImpl<$Res>
    implements _$PartiesDataCopyWith<$Res> {
  __$PartiesDataCopyWithImpl(this._self, this._then);

  final _PartiesData _self;
  final $Res Function(_PartiesData) _then;

/// Create a copy of PartiesData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? events = null,}) {
  return _then(_PartiesData(
events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<PartyEvent>,
  ));
}


}

// dart format on
