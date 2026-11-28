// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'water_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WaterEntry {

 num get amountMl; DateTime get timestamp;
/// Create a copy of WaterEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaterEntryCopyWith<WaterEntry> get copyWith => _$WaterEntryCopyWithImpl<WaterEntry>(this as WaterEntry, _$identity);

  /// Serializes this WaterEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WaterEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WaterEntry&&(identical(other.amountMl, _this.amountMl) || other.amountMl == _this.amountMl)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WaterEntry;
  return Object.hash(runtimeType,_this.amountMl,_this.timestamp);
}

@override
String toString() {
  final _this = this as WaterEntry;
  return 'WaterEntry(amountMl: ${_this.amountMl}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $WaterEntryCopyWith<$Res>  {
  factory $WaterEntryCopyWith(WaterEntry value, $Res Function(WaterEntry) _then) = _$WaterEntryCopyWithImpl;
@useResult
$Res call({
 num amountMl, DateTime timestamp
});




}
/// @nodoc
class _$WaterEntryCopyWithImpl<$Res>
    implements $WaterEntryCopyWith<$Res> {
  _$WaterEntryCopyWithImpl(this._self, this._then);

  final WaterEntry _self;
  final $Res Function(WaterEntry) _then;

/// Create a copy of WaterEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amountMl = null,Object? timestamp = null,}) {
  return _then(WaterEntry(
amountMl: null == amountMl ? _self.amountMl : amountMl // ignore: cast_nullable_to_non_nullable
as num,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WaterEntry].
extension WaterEntryPatterns on WaterEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WaterEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WaterEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WaterEntry value)  $default,){
final _that = this;
switch (_that) {
case _WaterEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WaterEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WaterEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num amountMl,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WaterEntry() when $default != null:
return $default(_that.amountMl,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num amountMl,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _WaterEntry():
return $default(_that.amountMl,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num amountMl,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _WaterEntry() when $default != null:
return $default(_that.amountMl,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WaterEntry implements WaterEntry {
  const _WaterEntry({required this.amountMl, required this.timestamp});
  factory _WaterEntry.fromJson(Map<String, dynamic> json) => _$WaterEntryFromJson(json);

@override final  num amountMl;
@override final  DateTime timestamp;

/// Create a copy of WaterEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaterEntryCopyWith<_WaterEntry> get copyWith => __$WaterEntryCopyWithImpl<_WaterEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaterEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WaterEntry&&(identical(other.amountMl, amountMl) || other.amountMl == amountMl)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,amountMl,timestamp);
}

@override
String toString() {
    return 'WaterEntry(amountMl: $amountMl, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$WaterEntryCopyWith<$Res> implements $WaterEntryCopyWith<$Res> {
  factory _$WaterEntryCopyWith(_WaterEntry value, $Res Function(_WaterEntry) _then) = __$WaterEntryCopyWithImpl;
@override @useResult
$Res call({
 num amountMl, DateTime timestamp
});




}
/// @nodoc
class __$WaterEntryCopyWithImpl<$Res>
    implements _$WaterEntryCopyWith<$Res> {
  __$WaterEntryCopyWithImpl(this._self, this._then);

  final _WaterEntry _self;
  final $Res Function(_WaterEntry) _then;

/// Create a copy of WaterEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amountMl = null,Object? timestamp = null,}) {
  return _then(_WaterEntry(
amountMl: null == amountMl ? _self.amountMl : amountMl // ignore: cast_nullable_to_non_nullable
as num,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$WaterData {

 num get consumed; num get goal; List<WaterEntry> get entries;
/// Create a copy of WaterData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaterDataCopyWith<WaterData> get copyWith => _$WaterDataCopyWithImpl<WaterData>(this as WaterData, _$identity);

  /// Serializes this WaterData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WaterData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WaterData&&(identical(other.consumed, _this.consumed) || other.consumed == _this.consumed)&&(identical(other.goal, _this.goal) || other.goal == _this.goal)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WaterData;
  return Object.hash(runtimeType,_this.consumed,_this.goal,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as WaterData;
  return 'WaterData(consumed: ${_this.consumed}, goal: ${_this.goal}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $WaterDataCopyWith<$Res>  {
  factory $WaterDataCopyWith(WaterData value, $Res Function(WaterData) _then) = _$WaterDataCopyWithImpl;
@useResult
$Res call({
 num consumed, num goal, List<WaterEntry> entries
});




}
/// @nodoc
class _$WaterDataCopyWithImpl<$Res>
    implements $WaterDataCopyWith<$Res> {
  _$WaterDataCopyWithImpl(this._self, this._then);

  final WaterData _self;
  final $Res Function(WaterData) _then;

/// Create a copy of WaterData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? consumed = null,Object? goal = null,Object? entries = null,}) {
  return _then(WaterData(
consumed: null == consumed ? _self.consumed : consumed // ignore: cast_nullable_to_non_nullable
as num,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as num,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<WaterEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [WaterData].
extension WaterDataPatterns on WaterData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WaterData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WaterData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WaterData value)  $default,){
final _that = this;
switch (_that) {
case _WaterData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WaterData value)?  $default,){
final _that = this;
switch (_that) {
case _WaterData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num consumed,  num goal,  List<WaterEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WaterData() when $default != null:
return $default(_that.consumed,_that.goal,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num consumed,  num goal,  List<WaterEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _WaterData():
return $default(_that.consumed,_that.goal,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num consumed,  num goal,  List<WaterEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _WaterData() when $default != null:
return $default(_that.consumed,_that.goal,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WaterData implements WaterData {
  const _WaterData({required this.consumed, required this.goal,  List<WaterEntry> entries = const []}): _entries = entries;
  factory _WaterData.fromJson(Map<String, dynamic> json) => _$WaterDataFromJson(json);

@override final  num consumed;
@override final  num goal;
 final  List<WaterEntry> _entries;
@override@JsonKey() List<WaterEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of WaterData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaterDataCopyWith<_WaterData> get copyWith => __$WaterDataCopyWithImpl<_WaterData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaterDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WaterData&&(identical(other.consumed, consumed) || other.consumed == consumed)&&(identical(other.goal, goal) || other.goal == goal)&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,consumed,goal,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'WaterData(consumed: $consumed, goal: $goal, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$WaterDataCopyWith<$Res> implements $WaterDataCopyWith<$Res> {
  factory _$WaterDataCopyWith(_WaterData value, $Res Function(_WaterData) _then) = __$WaterDataCopyWithImpl;
@override @useResult
$Res call({
 num consumed, num goal, List<WaterEntry> entries
});




}
/// @nodoc
class __$WaterDataCopyWithImpl<$Res>
    implements _$WaterDataCopyWith<$Res> {
  __$WaterDataCopyWithImpl(this._self, this._then);

  final _WaterData _self;
  final $Res Function(_WaterData) _then;

/// Create a copy of WaterData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? consumed = null,Object? goal = null,Object? entries = null,}) {
  return _then(_WaterData(
consumed: null == consumed ? _self.consumed : consumed // ignore: cast_nullable_to_non_nullable
as num,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as num,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<WaterEntry>,
  ));
}


}

// dart format on
