// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protein_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProteinMeal {

 String get name; num get protein; String? get time;
/// Create a copy of ProteinMeal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProteinMealCopyWith<ProteinMeal> get copyWith => _$ProteinMealCopyWithImpl<ProteinMeal>(this as ProteinMeal, _$identity);

  /// Serializes this ProteinMeal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProteinMeal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProteinMeal&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.protein, _this.protein) || other.protein == _this.protein)&&(identical(other.time, _this.time) || other.time == _this.time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProteinMeal;
  return Object.hash(runtimeType,_this.name,_this.protein,_this.time);
}

@override
String toString() {
  final _this = this as ProteinMeal;
  return 'ProteinMeal(name: ${_this.name}, protein: ${_this.protein}, time: ${_this.time})';
}


}

/// @nodoc
abstract mixin class $ProteinMealCopyWith<$Res>  {
  factory $ProteinMealCopyWith(ProteinMeal value, $Res Function(ProteinMeal) _then) = _$ProteinMealCopyWithImpl;
@useResult
$Res call({
 String name, num protein, String? time
});




}
/// @nodoc
class _$ProteinMealCopyWithImpl<$Res>
    implements $ProteinMealCopyWith<$Res> {
  _$ProteinMealCopyWithImpl(this._self, this._then);

  final ProteinMeal _self;
  final $Res Function(ProteinMeal) _then;

/// Create a copy of ProteinMeal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? protein = null,Object? time = freezed,}) {
  return _then(ProteinMeal(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as num,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProteinMeal].
extension ProteinMealPatterns on ProteinMeal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProteinMeal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProteinMeal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProteinMeal value)  $default,){
final _that = this;
switch (_that) {
case _ProteinMeal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProteinMeal value)?  $default,){
final _that = this;
switch (_that) {
case _ProteinMeal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  num protein,  String? time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProteinMeal() when $default != null:
return $default(_that.name,_that.protein,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  num protein,  String? time)  $default,) {final _that = this;
switch (_that) {
case _ProteinMeal():
return $default(_that.name,_that.protein,_that.time);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  num protein,  String? time)?  $default,) {final _that = this;
switch (_that) {
case _ProteinMeal() when $default != null:
return $default(_that.name,_that.protein,_that.time);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProteinMeal implements ProteinMeal {
  const _ProteinMeal({required this.name, required this.protein, this.time});
  factory _ProteinMeal.fromJson(Map<String, dynamic> json) => _$ProteinMealFromJson(json);

@override final  String name;
@override final  num protein;
@override final  String? time;

/// Create a copy of ProteinMeal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProteinMealCopyWith<_ProteinMeal> get copyWith => __$ProteinMealCopyWithImpl<_ProteinMeal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProteinMealToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProteinMeal&&(identical(other.name, name) || other.name == name)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,protein,time);
}

@override
String toString() {
    return 'ProteinMeal(name: $name, protein: $protein, time: $time)';
}


}

/// @nodoc
abstract mixin class _$ProteinMealCopyWith<$Res> implements $ProteinMealCopyWith<$Res> {
  factory _$ProteinMealCopyWith(_ProteinMeal value, $Res Function(_ProteinMeal) _then) = __$ProteinMealCopyWithImpl;
@override @useResult
$Res call({
 String name, num protein, String? time
});




}
/// @nodoc
class __$ProteinMealCopyWithImpl<$Res>
    implements _$ProteinMealCopyWith<$Res> {
  __$ProteinMealCopyWithImpl(this._self, this._then);

  final _ProteinMeal _self;
  final $Res Function(_ProteinMeal) _then;

/// Create a copy of ProteinMeal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? protein = null,Object? time = freezed,}) {
  return _then(_ProteinMeal(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as num,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProteinData {

 num get consumed; num get goal; List<ProteinMeal> get meals;
/// Create a copy of ProteinData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProteinDataCopyWith<ProteinData> get copyWith => _$ProteinDataCopyWithImpl<ProteinData>(this as ProteinData, _$identity);

  /// Serializes this ProteinData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProteinData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProteinData&&(identical(other.consumed, _this.consumed) || other.consumed == _this.consumed)&&(identical(other.goal, _this.goal) || other.goal == _this.goal)&&const DeepCollectionEquality().equals(other.meals, _this.meals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProteinData;
  return Object.hash(runtimeType,_this.consumed,_this.goal,const DeepCollectionEquality().hash(_this.meals));
}

@override
String toString() {
  final _this = this as ProteinData;
  return 'ProteinData(consumed: ${_this.consumed}, goal: ${_this.goal}, meals: ${_this.meals})';
}


}

/// @nodoc
abstract mixin class $ProteinDataCopyWith<$Res>  {
  factory $ProteinDataCopyWith(ProteinData value, $Res Function(ProteinData) _then) = _$ProteinDataCopyWithImpl;
@useResult
$Res call({
 num consumed, num goal, List<ProteinMeal> meals
});




}
/// @nodoc
class _$ProteinDataCopyWithImpl<$Res>
    implements $ProteinDataCopyWith<$Res> {
  _$ProteinDataCopyWithImpl(this._self, this._then);

  final ProteinData _self;
  final $Res Function(ProteinData) _then;

/// Create a copy of ProteinData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? consumed = null,Object? goal = null,Object? meals = null,}) {
  return _then(ProteinData(
consumed: null == consumed ? _self.consumed : consumed // ignore: cast_nullable_to_non_nullable
as num,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as num,meals: null == meals ? _self.meals : meals // ignore: cast_nullable_to_non_nullable
as List<ProteinMeal>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProteinData].
extension ProteinDataPatterns on ProteinData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProteinData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProteinData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProteinData value)  $default,){
final _that = this;
switch (_that) {
case _ProteinData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProteinData value)?  $default,){
final _that = this;
switch (_that) {
case _ProteinData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num consumed,  num goal,  List<ProteinMeal> meals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProteinData() when $default != null:
return $default(_that.consumed,_that.goal,_that.meals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num consumed,  num goal,  List<ProteinMeal> meals)  $default,) {final _that = this;
switch (_that) {
case _ProteinData():
return $default(_that.consumed,_that.goal,_that.meals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num consumed,  num goal,  List<ProteinMeal> meals)?  $default,) {final _that = this;
switch (_that) {
case _ProteinData() when $default != null:
return $default(_that.consumed,_that.goal,_that.meals);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProteinData implements ProteinData {
  const _ProteinData({required this.consumed, required this.goal,  List<ProteinMeal> meals = const []}): _meals = meals;
  factory _ProteinData.fromJson(Map<String, dynamic> json) => _$ProteinDataFromJson(json);

@override final  num consumed;
@override final  num goal;
 final  List<ProteinMeal> _meals;
@override@JsonKey() List<ProteinMeal> get meals {
  if (_meals is EqualUnmodifiableListView) return _meals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meals);
}


/// Create a copy of ProteinData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProteinDataCopyWith<_ProteinData> get copyWith => __$ProteinDataCopyWithImpl<_ProteinData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProteinDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProteinData&&(identical(other.consumed, consumed) || other.consumed == consumed)&&(identical(other.goal, goal) || other.goal == goal)&&const DeepCollectionEquality().equals(other.meals, _meals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,consumed,goal,const DeepCollectionEquality().hash(_meals));
}

@override
String toString() {
    return 'ProteinData(consumed: $consumed, goal: $goal, meals: $meals)';
}


}

/// @nodoc
abstract mixin class _$ProteinDataCopyWith<$Res> implements $ProteinDataCopyWith<$Res> {
  factory _$ProteinDataCopyWith(_ProteinData value, $Res Function(_ProteinData) _then) = __$ProteinDataCopyWithImpl;
@override @useResult
$Res call({
 num consumed, num goal, List<ProteinMeal> meals
});




}
/// @nodoc
class __$ProteinDataCopyWithImpl<$Res>
    implements _$ProteinDataCopyWith<$Res> {
  __$ProteinDataCopyWithImpl(this._self, this._then);

  final _ProteinData _self;
  final $Res Function(_ProteinData) _then;

/// Create a copy of ProteinData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? consumed = null,Object? goal = null,Object? meals = null,}) {
  return _then(_ProteinData(
consumed: null == consumed ? _self.consumed : consumed // ignore: cast_nullable_to_non_nullable
as num,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as num,meals: null == meals ? _self._meals : meals // ignore: cast_nullable_to_non_nullable
as List<ProteinMeal>,
  ));
}


}

// dart format on
