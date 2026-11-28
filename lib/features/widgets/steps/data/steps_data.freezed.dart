// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'steps_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StepsData {

 num get steps; num get goal; num get distanceKm; num get calories; int get streak;
/// Create a copy of StepsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepsDataCopyWith<StepsData> get copyWith => _$StepsDataCopyWithImpl<StepsData>(this as StepsData, _$identity);

  /// Serializes this StepsData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StepsData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StepsData&&(identical(other.steps, _this.steps) || other.steps == _this.steps)&&(identical(other.goal, _this.goal) || other.goal == _this.goal)&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.calories, _this.calories) || other.calories == _this.calories)&&(identical(other.streak, _this.streak) || other.streak == _this.streak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StepsData;
  return Object.hash(runtimeType,_this.steps,_this.goal,_this.distanceKm,_this.calories,_this.streak);
}

@override
String toString() {
  final _this = this as StepsData;
  return 'StepsData(steps: ${_this.steps}, goal: ${_this.goal}, distanceKm: ${_this.distanceKm}, calories: ${_this.calories}, streak: ${_this.streak})';
}


}

/// @nodoc
abstract mixin class $StepsDataCopyWith<$Res>  {
  factory $StepsDataCopyWith(StepsData value, $Res Function(StepsData) _then) = _$StepsDataCopyWithImpl;
@useResult
$Res call({
 num steps, num goal, num distanceKm, num calories, int streak
});




}
/// @nodoc
class _$StepsDataCopyWithImpl<$Res>
    implements $StepsDataCopyWith<$Res> {
  _$StepsDataCopyWithImpl(this._self, this._then);

  final StepsData _self;
  final $Res Function(StepsData) _then;

/// Create a copy of StepsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? steps = null,Object? goal = null,Object? distanceKm = null,Object? calories = null,Object? streak = null,}) {
  return _then(StepsData(
steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as num,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as num,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as num,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as num,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StepsData].
extension StepsDataPatterns on StepsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StepsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StepsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StepsData value)  $default,){
final _that = this;
switch (_that) {
case _StepsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StepsData value)?  $default,){
final _that = this;
switch (_that) {
case _StepsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num steps,  num goal,  num distanceKm,  num calories,  int streak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StepsData() when $default != null:
return $default(_that.steps,_that.goal,_that.distanceKm,_that.calories,_that.streak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num steps,  num goal,  num distanceKm,  num calories,  int streak)  $default,) {final _that = this;
switch (_that) {
case _StepsData():
return $default(_that.steps,_that.goal,_that.distanceKm,_that.calories,_that.streak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num steps,  num goal,  num distanceKm,  num calories,  int streak)?  $default,) {final _that = this;
switch (_that) {
case _StepsData() when $default != null:
return $default(_that.steps,_that.goal,_that.distanceKm,_that.calories,_that.streak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StepsData implements StepsData {
  const _StepsData({required this.steps, required this.goal, required this.distanceKm, required this.calories, this.streak = 0});
  factory _StepsData.fromJson(Map<String, dynamic> json) => _$StepsDataFromJson(json);

@override final  num steps;
@override final  num goal;
@override final  num distanceKm;
@override final  num calories;
@override@JsonKey() final  int streak;

/// Create a copy of StepsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StepsDataCopyWith<_StepsData> get copyWith => __$StepsDataCopyWithImpl<_StepsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StepsDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StepsData&&(identical(other.steps, steps) || other.steps == steps)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.streak, streak) || other.streak == streak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,steps,goal,distanceKm,calories,streak);
}

@override
String toString() {
    return 'StepsData(steps: $steps, goal: $goal, distanceKm: $distanceKm, calories: $calories, streak: $streak)';
}


}

/// @nodoc
abstract mixin class _$StepsDataCopyWith<$Res> implements $StepsDataCopyWith<$Res> {
  factory _$StepsDataCopyWith(_StepsData value, $Res Function(_StepsData) _then) = __$StepsDataCopyWithImpl;
@override @useResult
$Res call({
 num steps, num goal, num distanceKm, num calories, int streak
});




}
/// @nodoc
class __$StepsDataCopyWithImpl<$Res>
    implements _$StepsDataCopyWith<$Res> {
  __$StepsDataCopyWithImpl(this._self, this._then);

  final _StepsData _self;
  final $Res Function(_StepsData) _then;

/// Create a copy of StepsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? steps = null,Object? goal = null,Object? distanceKm = null,Object? calories = null,Object? streak = null,}) {
  return _then(_StepsData(
steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as num,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as num,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as num,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as num,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
