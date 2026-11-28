// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracker_base.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackerEntry {

 num get value; DateTime get timestamp; String? get note;
/// Create a copy of TrackerEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackerEntryCopyWith<TrackerEntry> get copyWith => _$TrackerEntryCopyWithImpl<TrackerEntry>(this as TrackerEntry, _$identity);

  /// Serializes this TrackerEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrackerEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackerEntry&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrackerEntry;
  return Object.hash(runtimeType,_this.value,_this.timestamp,_this.note);
}

@override
String toString() {
  final _this = this as TrackerEntry;
  return 'TrackerEntry(value: ${_this.value}, timestamp: ${_this.timestamp}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $TrackerEntryCopyWith<$Res>  {
  factory $TrackerEntryCopyWith(TrackerEntry value, $Res Function(TrackerEntry) _then) = _$TrackerEntryCopyWithImpl;
@useResult
$Res call({
 num value, DateTime timestamp, String? note
});




}
/// @nodoc
class _$TrackerEntryCopyWithImpl<$Res>
    implements $TrackerEntryCopyWith<$Res> {
  _$TrackerEntryCopyWithImpl(this._self, this._then);

  final TrackerEntry _self;
  final $Res Function(TrackerEntry) _then;

/// Create a copy of TrackerEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? timestamp = null,Object? note = freezed,}) {
  return _then(TrackerEntry(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackerEntry].
extension TrackerEntryPatterns on TrackerEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackerEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackerEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackerEntry value)  $default,){
final _that = this;
switch (_that) {
case _TrackerEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackerEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TrackerEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num value,  DateTime timestamp,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackerEntry() when $default != null:
return $default(_that.value,_that.timestamp,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num value,  DateTime timestamp,  String? note)  $default,) {final _that = this;
switch (_that) {
case _TrackerEntry():
return $default(_that.value,_that.timestamp,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num value,  DateTime timestamp,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _TrackerEntry() when $default != null:
return $default(_that.value,_that.timestamp,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackerEntry implements TrackerEntry {
  const _TrackerEntry({required this.value, required this.timestamp, this.note});
  factory _TrackerEntry.fromJson(Map<String, dynamic> json) => _$TrackerEntryFromJson(json);

@override final  num value;
@override final  DateTime timestamp;
@override final  String? note;

/// Create a copy of TrackerEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackerEntryCopyWith<_TrackerEntry> get copyWith => __$TrackerEntryCopyWithImpl<_TrackerEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackerEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackerEntry&&(identical(other.value, value) || other.value == value)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,value,timestamp,note);
}

@override
String toString() {
    return 'TrackerEntry(value: $value, timestamp: $timestamp, note: $note)';
}


}

/// @nodoc
abstract mixin class _$TrackerEntryCopyWith<$Res> implements $TrackerEntryCopyWith<$Res> {
  factory _$TrackerEntryCopyWith(_TrackerEntry value, $Res Function(_TrackerEntry) _then) = __$TrackerEntryCopyWithImpl;
@override @useResult
$Res call({
 num value, DateTime timestamp, String? note
});




}
/// @nodoc
class __$TrackerEntryCopyWithImpl<$Res>
    implements _$TrackerEntryCopyWith<$Res> {
  __$TrackerEntryCopyWithImpl(this._self, this._then);

  final _TrackerEntry _self;
  final $Res Function(_TrackerEntry) _then;

/// Create a copy of TrackerEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? timestamp = null,Object? note = freezed,}) {
  return _then(_TrackerEntry(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TrackerBase {

 num get target; String get unit; TimePeriod get period; List<TrackerEntry> get entries;
/// Create a copy of TrackerBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackerBaseCopyWith<TrackerBase> get copyWith => _$TrackerBaseCopyWithImpl<TrackerBase>(this as TrackerBase, _$identity);

  /// Serializes this TrackerBase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrackerBase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackerBase&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.period, _this.period) || other.period == _this.period)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrackerBase;
  return Object.hash(runtimeType,_this.target,_this.unit,_this.period,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as TrackerBase;
  return 'TrackerBase(target: ${_this.target}, unit: ${_this.unit}, period: ${_this.period}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $TrackerBaseCopyWith<$Res>  {
  factory $TrackerBaseCopyWith(TrackerBase value, $Res Function(TrackerBase) _then) = _$TrackerBaseCopyWithImpl;
@useResult
$Res call({
 num target, String unit, TimePeriod period, List<TrackerEntry> entries
});




}
/// @nodoc
class _$TrackerBaseCopyWithImpl<$Res>
    implements $TrackerBaseCopyWith<$Res> {
  _$TrackerBaseCopyWithImpl(this._self, this._then);

  final TrackerBase _self;
  final $Res Function(TrackerBase) _then;

/// Create a copy of TrackerBase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? unit = null,Object? period = null,Object? entries = null,}) {
  return _then(TrackerBase(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as num,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as TimePeriod,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<TrackerEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackerBase].
extension TrackerBasePatterns on TrackerBase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackerBase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackerBase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackerBase value)  $default,){
final _that = this;
switch (_that) {
case _TrackerBase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackerBase value)?  $default,){
final _that = this;
switch (_that) {
case _TrackerBase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num target,  String unit,  TimePeriod period,  List<TrackerEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackerBase() when $default != null:
return $default(_that.target,_that.unit,_that.period,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num target,  String unit,  TimePeriod period,  List<TrackerEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _TrackerBase():
return $default(_that.target,_that.unit,_that.period,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num target,  String unit,  TimePeriod period,  List<TrackerEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _TrackerBase() when $default != null:
return $default(_that.target,_that.unit,_that.period,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackerBase implements TrackerBase {
  const _TrackerBase({required this.target, required this.unit, this.period = TimePeriod.day,  List<TrackerEntry> entries = const []}): _entries = entries;
  factory _TrackerBase.fromJson(Map<String, dynamic> json) => _$TrackerBaseFromJson(json);

@override final  num target;
@override final  String unit;
@override@JsonKey() final  TimePeriod period;
 final  List<TrackerEntry> _entries;
@override@JsonKey() List<TrackerEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of TrackerBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackerBaseCopyWith<_TrackerBase> get copyWith => __$TrackerBaseCopyWithImpl<_TrackerBase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackerBaseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackerBase&&(identical(other.target, target) || other.target == target)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,target,unit,period,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'TrackerBase(target: $target, unit: $unit, period: $period, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$TrackerBaseCopyWith<$Res> implements $TrackerBaseCopyWith<$Res> {
  factory _$TrackerBaseCopyWith(_TrackerBase value, $Res Function(_TrackerBase) _then) = __$TrackerBaseCopyWithImpl;
@override @useResult
$Res call({
 num target, String unit, TimePeriod period, List<TrackerEntry> entries
});




}
/// @nodoc
class __$TrackerBaseCopyWithImpl<$Res>
    implements _$TrackerBaseCopyWith<$Res> {
  __$TrackerBaseCopyWithImpl(this._self, this._then);

  final _TrackerBase _self;
  final $Res Function(_TrackerBase) _then;

/// Create a copy of TrackerBase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? unit = null,Object? period = null,Object? entries = null,}) {
  return _then(_TrackerBase(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as num,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as TimePeriod,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<TrackerEntry>,
  ));
}


}

// dart format on
