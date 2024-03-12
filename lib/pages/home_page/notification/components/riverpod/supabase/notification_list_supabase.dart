import "package:flutter/material.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:share_your_q/utils/various.dart";
import "package:supabase_flutter/supabase_flutter.dart";

part "notification_list_supabase.g.dart";

@riverpod
class NotificationListSupabase extends _$NotificationListSupabase {

  @override
  Future<List<Map<String,dynamic>>> build() async {
    try{
      final response = await supabase
        .from("inquiries_reply")
        .select<List<Map<String,dynamic>>>()
        .eq("user_id", myUserId)
        .order("created_at", ascending: false);


      return response;

    }
    on PostgrestException catch (e) {
      
      return [];

    }
    catch(e){
      return [];
    }


    
  }

  // データを変更する関数
  void updateState() async {

    final response = await supabase
      .from("inquiries_reply")
      .select<List<Map<String,dynamic>>>("contents, created_at")
      .eq("user_id", myUserId)
      .order("created_at", ascending: false);

    debugPrint("updateState");


    state = AsyncValue.data(response);
    

  }

}
