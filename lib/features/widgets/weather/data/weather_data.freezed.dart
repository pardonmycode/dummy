// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherData {

 double get temperature; String get condition; String get icon; List<HourlyForecast> get hourly; List<DailyForecast> get daily;
/// Create a copy of WeatherData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherDataCopyWith<WeatherData> get copyWith => _$WeatherDataCopyWithImpl<WeatherData>(this as WeatherData, _$identity);

  /// Serializes this WeatherData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WeatherData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherData&&(identical(other.temperature, _this.temperature) || other.temperature == _this.temperature)&&(identical(other.condition, _this.condition) || other.condition == _this.condition)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&const DeepCollectionEquality().equals(other.hourly, _this.hourly)&&const DeepCollectionEquality().equals(other.daily, _this.daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WeatherData;
  return Object.hash(runtimeType,_this.temperature,_this.condition,_this.icon,const DeepCollectionEquality().hash(_this.hourly),const DeepCollectionEquality().hash(_this.daily));
}

@override
String toString() {
  final _this = this as WeatherData;
  return 'WeatherData(temperature: ${_this.temperature}, condition: ${_this.condition}, icon: ${_this.icon}, hourly: ${_this.hourly}, daily: ${_this.daily})';
}


}

/// @nodoc
abstract mixin class $WeatherDataCopyWith<$Res>  {
  factory $WeatherDataCopyWith(WeatherData value, $Res Function(WeatherData) _then) = _$WeatherDataCopyWithImpl;
@useResult
$Res call({
 double temperature, String condition, String icon, List<HourlyForecast> hourly, List<DailyForecast> daily
});




}
/// @nodoc
class _$WeatherDataCopyWithImpl<$Res>
    implements $WeatherDataCopyWith<$Res> {
  _$WeatherDataCopyWithImpl(this._self, this._then);

  final WeatherData _self;
  final $Res Function(WeatherData) _then;

/// Create a copy of WeatherData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? temperature = null,Object? condition = null,Object? icon = null,Object? hourly = null,Object? daily = null,}) {
  return _then(WeatherData(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,hourly: null == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as List<HourlyForecast>,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as List<DailyForecast>,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherData].
extension WeatherDataPatterns on WeatherData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherData value)  $default,){
final _that = this;
switch (_that) {
case _WeatherData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherData value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double temperature,  String condition,  String icon,  List<HourlyForecast> hourly,  List<DailyForecast> daily)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherData() when $default != null:
return $default(_that.temperature,_that.condition,_that.icon,_that.hourly,_that.daily);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double temperature,  String condition,  String icon,  List<HourlyForecast> hourly,  List<DailyForecast> daily)  $default,) {final _that = this;
switch (_that) {
case _WeatherData():
return $default(_that.temperature,_that.condition,_that.icon,_that.hourly,_that.daily);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double temperature,  String condition,  String icon,  List<HourlyForecast> hourly,  List<DailyForecast> daily)?  $default,) {final _that = this;
switch (_that) {
case _WeatherData() when $default != null:
return $default(_that.temperature,_that.condition,_that.icon,_that.hourly,_that.daily);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeatherData implements WeatherData {
  const _WeatherData({required this.temperature, required this.condition, required this.icon,  List<HourlyForecast> hourly = const [],  List<DailyForecast> daily = const []}): _hourly = hourly,_daily = daily;
  factory _WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);

@override final  double temperature;
@override final  String condition;
@override final  String icon;
 final  List<HourlyForecast> _hourly;
@override@JsonKey() List<HourlyForecast> get hourly {
  if (_hourly is EqualUnmodifiableListView) return _hourly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hourly);
}

 final  List<DailyForecast> _daily;
@override@JsonKey() List<DailyForecast> get daily {
  if (_daily is EqualUnmodifiableListView) return _daily;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daily);
}


/// Create a copy of WeatherData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherDataCopyWith<_WeatherData> get copyWith => __$WeatherDataCopyWithImpl<_WeatherData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherData&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.hourly, _hourly)&&const DeepCollectionEquality().equals(other.daily, _daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,temperature,condition,icon,const DeepCollectionEquality().hash(_hourly),const DeepCollectionEquality().hash(_daily));
}

@override
String toString() {
    return 'WeatherData(temperature: $temperature, condition: $condition, icon: $icon, hourly: $hourly, daily: $daily)';
}


}

/// @nodoc
abstract mixin class _$WeatherDataCopyWith<$Res> implements $WeatherDataCopyWith<$Res> {
  factory _$WeatherDataCopyWith(_WeatherData value, $Res Function(_WeatherData) _then) = __$WeatherDataCopyWithImpl;
@override @useResult
$Res call({
 double temperature, String condition, String icon, List<HourlyForecast> hourly, List<DailyForecast> daily
});




}
/// @nodoc
class __$WeatherDataCopyWithImpl<$Res>
    implements _$WeatherDataCopyWith<$Res> {
  __$WeatherDataCopyWithImpl(this._self, this._then);

  final _WeatherData _self;
  final $Res Function(_WeatherData) _then;

/// Create a copy of WeatherData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? temperature = null,Object? condition = null,Object? icon = null,Object? hourly = null,Object? daily = null,}) {
  return _then(_WeatherData(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,hourly: null == hourly ? _self._hourly : hourly // ignore: cast_nullable_to_non_nullable
as List<HourlyForecast>,daily: null == daily ? _self._daily : daily // ignore: cast_nullable_to_non_nullable
as List<DailyForecast>,
  ));
}


}


/// @nodoc
mixin _$HourlyForecast {

 String get time; double get temp; String get icon;
/// Create a copy of HourlyForecast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HourlyForecastCopyWith<HourlyForecast> get copyWith => _$HourlyForecastCopyWithImpl<HourlyForecast>(this as HourlyForecast, _$identity);

  /// Serializes this HourlyForecast to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HourlyForecast;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HourlyForecast&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.temp, _this.temp) || other.temp == _this.temp)&&(identical(other.icon, _this.icon) || other.icon == _this.icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HourlyForecast;
  return Object.hash(runtimeType,_this.time,_this.temp,_this.icon);
}

@override
String toString() {
  final _this = this as HourlyForecast;
  return 'HourlyForecast(time: ${_this.time}, temp: ${_this.temp}, icon: ${_this.icon})';
}


}

/// @nodoc
abstract mixin class $HourlyForecastCopyWith<$Res>  {
  factory $HourlyForecastCopyWith(HourlyForecast value, $Res Function(HourlyForecast) _then) = _$HourlyForecastCopyWithImpl;
@useResult
$Res call({
 String time, double temp, String icon
});




}
/// @nodoc
class _$HourlyForecastCopyWithImpl<$Res>
    implements $HourlyForecastCopyWith<$Res> {
  _$HourlyForecastCopyWithImpl(this._self, this._then);

  final HourlyForecast _self;
  final $Res Function(HourlyForecast) _then;

/// Create a copy of HourlyForecast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? temp = null,Object? icon = null,}) {
  return _then(HourlyForecast(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as double,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HourlyForecast].
extension HourlyForecastPatterns on HourlyForecast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HourlyForecast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HourlyForecast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HourlyForecast value)  $default,){
final _that = this;
switch (_that) {
case _HourlyForecast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HourlyForecast value)?  $default,){
final _that = this;
switch (_that) {
case _HourlyForecast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String time,  double temp,  String icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HourlyForecast() when $default != null:
return $default(_that.time,_that.temp,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String time,  double temp,  String icon)  $default,) {final _that = this;
switch (_that) {
case _HourlyForecast():
return $default(_that.time,_that.temp,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String time,  double temp,  String icon)?  $default,) {final _that = this;
switch (_that) {
case _HourlyForecast() when $default != null:
return $default(_that.time,_that.temp,_that.icon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HourlyForecast implements HourlyForecast {
  const _HourlyForecast({required this.time, required this.temp, required this.icon});
  factory _HourlyForecast.fromJson(Map<String, dynamic> json) => _$HourlyForecastFromJson(json);

@override final  String time;
@override final  double temp;
@override final  String icon;

/// Create a copy of HourlyForecast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HourlyForecastCopyWith<_HourlyForecast> get copyWith => __$HourlyForecastCopyWithImpl<_HourlyForecast>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HourlyForecastToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HourlyForecast&&(identical(other.time, time) || other.time == time)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,time,temp,icon);
}

@override
String toString() {
    return 'HourlyForecast(time: $time, temp: $temp, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$HourlyForecastCopyWith<$Res> implements $HourlyForecastCopyWith<$Res> {
  factory _$HourlyForecastCopyWith(_HourlyForecast value, $Res Function(_HourlyForecast) _then) = __$HourlyForecastCopyWithImpl;
@override @useResult
$Res call({
 String time, double temp, String icon
});




}
/// @nodoc
class __$HourlyForecastCopyWithImpl<$Res>
    implements _$HourlyForecastCopyWith<$Res> {
  __$HourlyForecastCopyWithImpl(this._self, this._then);

  final _HourlyForecast _self;
  final $Res Function(_HourlyForecast) _then;

/// Create a copy of HourlyForecast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? temp = null,Object? icon = null,}) {
  return _then(_HourlyForecast(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as double,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DailyForecast {

 String get date; double get high; double get low; String get icon;
/// Create a copy of DailyForecast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyForecastCopyWith<DailyForecast> get copyWith => _$DailyForecastCopyWithImpl<DailyForecast>(this as DailyForecast, _$identity);

  /// Serializes this DailyForecast to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DailyForecast;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyForecast&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.high, _this.high) || other.high == _this.high)&&(identical(other.low, _this.low) || other.low == _this.low)&&(identical(other.icon, _this.icon) || other.icon == _this.icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DailyForecast;
  return Object.hash(runtimeType,_this.date,_this.high,_this.low,_this.icon);
}

@override
String toString() {
  final _this = this as DailyForecast;
  return 'DailyForecast(date: ${_this.date}, high: ${_this.high}, low: ${_this.low}, icon: ${_this.icon})';
}


}

/// @nodoc
abstract mixin class $DailyForecastCopyWith<$Res>  {
  factory $DailyForecastCopyWith(DailyForecast value, $Res Function(DailyForecast) _then) = _$DailyForecastCopyWithImpl;
@useResult
$Res call({
 String date, double high, double low, String icon
});




}
/// @nodoc
class _$DailyForecastCopyWithImpl<$Res>
    implements $DailyForecastCopyWith<$Res> {
  _$DailyForecastCopyWithImpl(this._self, this._then);

  final DailyForecast _self;
  final $Res Function(DailyForecast) _then;

/// Create a copy of DailyForecast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? high = null,Object? low = null,Object? icon = null,}) {
  return _then(DailyForecast(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double,low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyForecast].
extension DailyForecastPatterns on DailyForecast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyForecast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyForecast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyForecast value)  $default,){
final _that = this;
switch (_that) {
case _DailyForecast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyForecast value)?  $default,){
final _that = this;
switch (_that) {
case _DailyForecast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  double high,  double low,  String icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyForecast() when $default != null:
return $default(_that.date,_that.high,_that.low,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  double high,  double low,  String icon)  $default,) {final _that = this;
switch (_that) {
case _DailyForecast():
return $default(_that.date,_that.high,_that.low,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  double high,  double low,  String icon)?  $default,) {final _that = this;
switch (_that) {
case _DailyForecast() when $default != null:
return $default(_that.date,_that.high,_that.low,_that.icon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyForecast implements DailyForecast {
  const _DailyForecast({required this.date, required this.high, required this.low, required this.icon});
  factory _DailyForecast.fromJson(Map<String, dynamic> json) => _$DailyForecastFromJson(json);

@override final  String date;
@override final  double high;
@override final  double low;
@override final  String icon;

/// Create a copy of DailyForecast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyForecastCopyWith<_DailyForecast> get copyWith => __$DailyForecastCopyWithImpl<_DailyForecast>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyForecastToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyForecast&&(identical(other.date, date) || other.date == date)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,high,low,icon);
}

@override
String toString() {
    return 'DailyForecast(date: $date, high: $high, low: $low, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$DailyForecastCopyWith<$Res> implements $DailyForecastCopyWith<$Res> {
  factory _$DailyForecastCopyWith(_DailyForecast value, $Res Function(_DailyForecast) _then) = __$DailyForecastCopyWithImpl;
@override @useResult
$Res call({
 String date, double high, double low, String icon
});




}
/// @nodoc
class __$DailyForecastCopyWithImpl<$Res>
    implements _$DailyForecastCopyWith<$Res> {
  __$DailyForecastCopyWithImpl(this._self, this._then);

  final _DailyForecast _self;
  final $Res Function(_DailyForecast) _then;

/// Create a copy of DailyForecast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? high = null,Object? low = null,Object? icon = null,}) {
  return _then(_DailyForecast(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double,low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
