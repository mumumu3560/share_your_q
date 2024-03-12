import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_your_q/pages/display_page/display_page.dart';
import 'package:share_your_q/pages/home_page/notification/components/notification_likes/notification_likes.dart';
import 'package:share_your_q/pages/home_page/notification/components/notification_others/notification_others.dart';
import 'package:share_your_q/pages/home_page/notification/components/riverpod/tab_notifier.dart';

import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import 'package:share_your_q/image_operations/image_list_display.dart';

//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';

//google_admob
//TODO ビルドリリースの時のみ
//import 'package:share_your_q/admob/inline_adaptive_banner.dart';


class NotificationPage extends ConsumerWidget{
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref){

    final tabs = ref.watch(tabNotifierProvider);


    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(text: "いいね "),
              Tab(text: "お知らせ "),
            ],
            onTap: (index) {
              ref.read(tabNotifierProvider.notifier).updateState(index);
            },
          ),
          
        ),
        body: TabBarView(
          children: [
            //通知
            Container(
              child: LikesNotificationList(),
            ),
            //お知らせ
            Container(
              child: OtherNotificationList(),
            ),
          ],
        ),
      ),
    );

    
  }

}