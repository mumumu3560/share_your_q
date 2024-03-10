/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'my_page_notifier.freezed.dart';

@freezed
abstract class NotificationPageState with _$NotificationPageState {
  const factory NotificationPageState({
    @Default(0) int count,
  }) = _NotificationPageState;
}

class NotificationPageNotifier extends StateNotifier<NotificationPageState>  {
  NotificationPageNotifier({
    required this.context,
  }) : super(const NotificationPageState());

  final BuildContext context;

  @override
  void dispose() {
    debugPrint('dispose');
    super.dispose();
  }

  @override
  void initState() {}
}


 */