// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'widget_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WidgetData {

 int get schemaVersion; Map<String, dynamic> get data; List<Map<String, dynamic>> get sources;@JsonKey(fromJson: _generatedAtFromJson) DateTime get generatedAt; DateTime? get expiresAt;
/// Create a copy of WidgetData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetDataCopyWith<WidgetData> get copyWith => _$WidgetDataCopyWithImpl<WidgetData>(this as WidgetData, _$identity);

  /// Serializes this WidgetData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WidgetData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetData&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&const DeepCollectionEquality().equals(other.data, _this.data)&&const DeepCollectionEquality().equals(other.sources, _this.sources)&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WidgetData;
  return Object.hash(runtimeType,_this.schemaVersion,const DeepCollectionEquality().hash(_this.data),const DeepCollectionEquality().hash(_this.sources),_this.generatedAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as WidgetData;
  return 'WidgetData(schemaVersion: ${_this.schemaVersion}, data: ${_this.data}, sources: ${_this.sources}, generatedAt: ${_this.generatedAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $WidgetDataCopyWith<$Res>  {
  factory $WidgetDataCopyWith(WidgetData value, $Res Function(WidgetData) _then) = _$WidgetDataCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, Map<String, dynamic> data, List<Map<String, dynamic>> sources,@JsonKey(fromJson: _generatedAtFromJson) DateTime generatedAt, DateTime? expiresAt
});




}
/// @nodoc
class _$WidgetDataCopyWithImpl<$Res>
    implements $WidgetDataCopyWith<$Res> {
  _$WidgetDataCopyWithImpl(this._self, this._then);

  final WidgetData _self;
  final $Res Function(WidgetData) _then;

/// Create a copy of WidgetData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? data = null,Object? sources = null,Object? generatedAt = null,Object? expiresAt = freezed,}) {
  return _then(WidgetData(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WidgetData].
extension WidgetDataPatterns on WidgetData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetData value)  $default,){
final _that = this;
switch (_that) {
case _WidgetData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetData value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  Map<String, dynamic> data,  List<Map<String, dynamic>> sources, @JsonKey(fromJson: _generatedAtFromJson)  DateTime generatedAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetData() when $default != null:
return $default(_that.schemaVersion,_that.data,_that.sources,_that.generatedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  Map<String, dynamic> data,  List<Map<String, dynamic>> sources, @JsonKey(fromJson: _generatedAtFromJson)  DateTime generatedAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _WidgetData():
return $default(_that.schemaVersion,_that.data,_that.sources,_that.generatedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  Map<String, dynamic> data,  List<Map<String, dynamic>> sources, @JsonKey(fromJson: _generatedAtFromJson)  DateTime generatedAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _WidgetData() when $default != null:
return $default(_that.schemaVersion,_that.data,_that.sources,_that.generatedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WidgetData implements WidgetData {
  const _WidgetData({this.schemaVersion = 1,  Map<String, dynamic> data = const {},  List<Map<String, dynamic>> sources = const [], @JsonKey(fromJson: _generatedAtFromJson) required this.generatedAt, this.expiresAt}): _data = data,_sources = sources;
  factory _WidgetData.fromJson(Map<String, dynamic> json) => _$WidgetDataFromJson(json);

@override@JsonKey() final  int schemaVersion;
 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

 final  List<Map<String, dynamic>> _sources;
@override@JsonKey() List<Map<String, dynamic>> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

@override@JsonKey(fromJson: _generatedAtFromJson) final  DateTime generatedAt;
@override final  DateTime? expiresAt;

/// Create a copy of WidgetData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetDataCopyWith<_WidgetData> get copyWith => __$WidgetDataCopyWithImpl<_WidgetData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WidgetDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetData&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&const DeepCollectionEquality().equals(other.data, _data)&&const DeepCollectionEquality().equals(other.sources, _sources)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,const DeepCollectionEquality().hash(_data),const DeepCollectionEquality().hash(_sources),generatedAt,expiresAt);
}

@override
String toString() {
    return 'WidgetData(schemaVersion: $schemaVersion, data: $data, sources: $sources, generatedAt: $generatedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$WidgetDataCopyWith<$Res> implements $WidgetDataCopyWith<$Res> {
  factory _$WidgetDataCopyWith(_WidgetData value, $Res Function(_WidgetData) _then) = __$WidgetDataCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, Map<String, dynamic> data, List<Map<String, dynamic>> sources,@JsonKey(fromJson: _generatedAtFromJson) DateTime generatedAt, DateTime? expiresAt
});




}
/// @nodoc
class __$WidgetDataCopyWithImpl<$Res>
    implements _$WidgetDataCopyWith<$Res> {
  __$WidgetDataCopyWithImpl(this._self, this._then);

  final _WidgetData _self;
  final $Res Function(_WidgetData) _then;

/// Create a copy of WidgetData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? data = null,Object? sources = null,Object? generatedAt = null,Object? expiresAt = freezed,}) {
  return _then(_WidgetData(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
