// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shikoku.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Shikoku {
  int get kagawa => throw _privateConstructorUsedError;
  int get tokushima => throw _privateConstructorUsedError;
  int get kouchi => throw _privateConstructorUsedError;
  int get ehime => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ShikokuCopyWith<Shikoku> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShikokuCopyWith<$Res> {
  factory $ShikokuCopyWith(Shikoku value, $Res Function(Shikoku) then) =
      _$ShikokuCopyWithImpl<$Res, Shikoku>;
  @useResult
  $Res call({int kagawa, int tokushima, int kouchi, int ehime});
}

/// @nodoc
class _$ShikokuCopyWithImpl<$Res, $Val extends Shikoku>
    implements $ShikokuCopyWith<$Res> {
  _$ShikokuCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kagawa = null,
    Object? tokushima = null,
    Object? kouchi = null,
    Object? ehime = null,
  }) {
    return _then(_value.copyWith(
      kagawa: null == kagawa
          ? _value.kagawa
          : kagawa // ignore: cast_nullable_to_non_nullable
              as int,
      tokushima: null == tokushima
          ? _value.tokushima
          : tokushima // ignore: cast_nullable_to_non_nullable
              as int,
      kouchi: null == kouchi
          ? _value.kouchi
          : kouchi // ignore: cast_nullable_to_non_nullable
              as int,
      ehime: null == ehime
          ? _value.ehime
          : ehime // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShikokuImplCopyWith<$Res> implements $ShikokuCopyWith<$Res> {
  factory _$$ShikokuImplCopyWith(
          _$ShikokuImpl value, $Res Function(_$ShikokuImpl) then) =
      __$$ShikokuImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int kagawa, int tokushima, int kouchi, int ehime});
}

/// @nodoc
class __$$ShikokuImplCopyWithImpl<$Res>
    extends _$ShikokuCopyWithImpl<$Res, _$ShikokuImpl>
    implements _$$ShikokuImplCopyWith<$Res> {
  __$$ShikokuImplCopyWithImpl(
      _$ShikokuImpl _value, $Res Function(_$ShikokuImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kagawa = null,
    Object? tokushima = null,
    Object? kouchi = null,
    Object? ehime = null,
  }) {
    return _then(_$ShikokuImpl(
      kagawa: null == kagawa
          ? _value.kagawa
          : kagawa // ignore: cast_nullable_to_non_nullable
              as int,
      tokushima: null == tokushima
          ? _value.tokushima
          : tokushima // ignore: cast_nullable_to_non_nullable
              as int,
      kouchi: null == kouchi
          ? _value.kouchi
          : kouchi // ignore: cast_nullable_to_non_nullable
              as int,
      ehime: null == ehime
          ? _value.ehime
          : ehime // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ShikokuImpl implements _Shikoku {
  const _$ShikokuImpl(
      {required this.kagawa,
      required this.tokushima,
      required this.kouchi,
      required this.ehime});

  @override
  final int kagawa;
  @override
  final int tokushima;
  @override
  final int kouchi;
  @override
  final int ehime;

  @override
  String toString() {
    return 'Shikoku(kagawa: $kagawa, tokushima: $tokushima, kouchi: $kouchi, ehime: $ehime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShikokuImpl &&
            (identical(other.kagawa, kagawa) || other.kagawa == kagawa) &&
            (identical(other.tokushima, tokushima) ||
                other.tokushima == tokushima) &&
            (identical(other.kouchi, kouchi) || other.kouchi == kouchi) &&
            (identical(other.ehime, ehime) || other.ehime == ehime));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, kagawa, tokushima, kouchi, ehime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShikokuImplCopyWith<_$ShikokuImpl> get copyWith =>
      __$$ShikokuImplCopyWithImpl<_$ShikokuImpl>(this, _$identity);
}

abstract class _Shikoku implements Shikoku {
  const factory _Shikoku(
      {required final int kagawa,
      required final int tokushima,
      required final int kouchi,
      required final int ehime}) = _$ShikokuImpl;

  @override
  int get kagawa;
  @override
  int get tokushima;
  @override
  int get kouchi;
  @override
  int get ehime;
  @override
  @JsonKey(ignore: true)
  _$$ShikokuImplCopyWith<_$ShikokuImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
