import 'package:flutter/material.dart';

import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';


//google_admob
//TODO ビルドリリースの時のみ
//import 'package:share_your_q/admob/inline_adaptive_banner.dart';

String textKeeper = "";




//ここはsupabaseから取得したデータの内容を表示するためのウィジェット
class CommentItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isRes;
  const CommentItem({

    Key? key,
    required this.item,

    required this.isRes,
    
  }): super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}


class _CommentItemState extends State<CommentItem> with AutomaticKeepAliveClientMixin {
  String profileImageId = '';
  String userName = '';
  bool isLoading = true; // ローディング状態を管理するフラグ

  @override
  void initState() {
    super.initState();
    fetchUserProfileAndImage();
  }

  Future<void> fetchUserProfileAndImage() async {
    try {
      final profileResponse = await supabase
        .from('profiles')
        .select()
        .eq('id', widget.item['user_id'])
        .single();

      if (mounted) {
        setState(() {
          userName = profileResponse['username'];
          profileImageId = profileResponse['profile_image_id'] ?? '';
          isLoading = false; // ローディング完了
        });
      }
    } catch (e) {
      // エラーハンドリングを適宜行う
      print('Error fetching user profile: $e');
      if (mounted) {
        setState(() {
          isLoading = false; // ローディング完了
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ローディング中はローディングインジケータを表示
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // ローディング完了後は実際のUIを表示
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(profileImageId.isEmpty ? 'デフォルト画像のURL' : profileImageId),
        ),
        title: Text(userName),
        // 他のUI部品...
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
