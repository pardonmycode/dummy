// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'widget_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WidgetInstance {

 String get id; String get widgetType; WidgetSize get size;@JsonKey(fromJson: _configFromJson) Map<String, dynamic> get config;@JsonKey(fromJson: _gridPositionFromJson) Map<String, int> get gridPosition;
/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetInstanceCopyWith<WidgetInstance> get copyWith => _$WidgetInstanceCopyWithImpl<WidgetInstance>(this as WidgetInstance, _$identity);

  /// Serializes this WidgetInstance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WidgetInstance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetInstance&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.widgetType, _this.widgetType) || other.widgetType == _this.widgetType)&&(identical(other.size, _this.size) || other.size == _this.size)&&const DeepCollectionEquality().equals(other.config, _this.config)&&const DeepCollectionEquality().equals(other.gridPosition, _this.gridPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WidgetInstance;
  return Object.hash(runtimeType,_this.id,_this.widgetType,_this.size,const DeepCollectionEquality().hash(_this.config),const DeepCollectionEquality().hash(_this.gridPosition));
}

@override
String toString() {
  final _this = this as WidgetInstance;
  return 'WidgetInstance(id: ${_this.id}, widgetType: ${_this.widgetType}, size: ${_this.size}, config: ${_this.config}, gridPosition: ${_this.gridPosition})';
}


}

/// @nodoc
abstract mixin class $WidgetInstanceCopyWith<$Res>  {
  factory $WidgetInstanceCopyWith(WidgetInstance value, $Res Function(WidgetInstance) _then) = _$WidgetInstanceCopyWithImpl;
@useResult
$Res call({
 String id, String widgetType, WidgetSize size,@JsonKey(fromJson: _configFromJson) Map<String, dynamic> config,@JsonKey(fromJson: _gridPositionFromJson) Map<String, int> gridPosition
});




}
/// @nodoc
class _$WidgetInstanceCopyWithImpl<$Res>
    implements $WidgetInstanceCopyWith<$Res> {
  _$WidgetInstanceCopyWithImpl(this._self, this._then);

  final WidgetInstance _self;
  final $Res Function(WidgetInstance) _then;

/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? widgetType = null,Object? size = null,Object? config = null,Object? gridPosition = null,}) {
  return _then(WidgetInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,widgetType: null == widgetType ? _self.widgetType : widgetType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as WidgetSize,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,gridPosition: null == gridPosition ? _self.gridPosition : gridPosition // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [WidgetInstance].
extension WidgetInstancePatterns on WidgetInstance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetInstance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetInstance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetInstance value)  $default,){
final _that = this;
switch (_that) {
case _WidgetInstance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetInstance value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetInstance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String widgetType,  WidgetSize size, @JsonKey(fromJson: _configFromJson)  Map<String, dynamic> config, @JsonKey(fromJson: _gridPositionFromJson)  Map<String, int> gridPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetInstance() when $default != null:
return $default(_that.id,_that.widgetType,_that.size,_that.config,_that.gridPosition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String widgetType,  WidgetSize size, @JsonKey(fromJson: _configFromJson)  Map<String, dynamic> config, @JsonKey(fromJson: _gridPositionFromJson)  Map<String, int> gridPosition)  $default,) {final _that = this;
switch (_that) {
case _WidgetInstance():
return $default(_that.id,_that.widgetType,_that.size,_that.config,_that.gridPosition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String widgetType,  WidgetSize size, @JsonKey(fromJson: _configFromJson)  Map<String, dynamic> config, @JsonKey(fromJson: _gridPositionFromJson)  Map<String, int> gridPosition)?  $default,) {final _that = this;
switch (_that) {
case _WidgetInstance() when $default != null:
return $default(_that.id,_that.widgetType,_that.size,_that.config,_that.gridPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WidgetInstance implements WidgetInstance {
  const _WidgetInstance({this.id = '', required this.widgetType, this.size = WidgetSize.medium, @JsonKey(fromJson: _configFromJson)  Map<String, dynamic> config = const {}, @JsonKey(fromJson: _gridPositionFromJson)  Map<String, int> gridPosition = const {'row' : 0, 'col' : 0, 'rowSpan' : 1, 'colSpan' : 1}}): _config = config,_gridPosition = gridPosition;
  factory _WidgetInstance.fromJson(Map<String, dynamic> json) => _$WidgetInstanceFromJson(json);

@override@JsonKey() final  String id;
@override final  String widgetType;
@override@JsonKey() final  WidgetSize size;
 final  Map<String, dynamic> _config;
@override@JsonKey(fromJson: _configFromJson) Map<String, dynamic> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}

 final  Map<String, int> _gridPosition;
@override@JsonKey(fromJson: _gridPositionFromJson) Map<String, int> get gridPosition {
  if (_gridPosition is EqualUnmodifiableMapView) return _gridPosition;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_gridPosition);
}


/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetInstanceCopyWith<_WidgetInstance> get copyWith => __$WidgetInstanceCopyWithImpl<_WidgetInstance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WidgetInstanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.widgetType, widgetType) || other.widgetType == widgetType)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.config, _config)&&const DeepCollectionEquality().equals(other.gridPosition, _gridPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,widgetType,size,const DeepCollectionEquality().hash(_config),const DeepCollectionEquality().hash(_gridPosition));
}

@override
String toString() {
    return 'WidgetInstance(id: $id, widgetType: $widgetType, size: $size, config: $config, gridPosition: $gridPosition)';
}


}

/// @nodoc
abstract mixin class _$WidgetInstanceCopyWith<$Res> implements $WidgetInstanceCopyWith<$Res> {
  factory _$WidgetInstanceCopyWith(_WidgetInstance value, $Res Function(_WidgetInstance) _then) = __$WidgetInstanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String widgetType, WidgetSize size,@JsonKey(fromJson: _configFromJson) Map<String, dynamic> config,@JsonKey(fromJson: _gridPositionFromJson) Map<String, int> gridPosition
});




}
/// @nodoc
class __$WidgetInstanceCopyWithImpl<$Res>
    implements _$WidgetInstanceCopyWith<$Res> {
  __$WidgetInstanceCopyWithImpl(this._self, this._then);

  final _WidgetInstance _self;
  final $Res Function(_WidgetInstance) _then;

/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? widgetType = null,Object? size = null,Object? config = null,Object? gridPosition = null,}) {
  return _then(_WidgetInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,widgetType: null == widgetType ? _self.widgetType : widgetType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as WidgetSize,config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,gridPosition: null == gridPosition ? _self._gridPosition : gridPosition // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
