import "package:freezed_annotation/freezed_annotation.dart";

part "shikoku.freezed.dart";

@freezed
class Shikoku with _$Shikoku{

  const factory Shikoku({
    required int kagawa,
    required int tokushima,
    required int kouchi,
    required int ehime,
  }) = _Shikoku;




}