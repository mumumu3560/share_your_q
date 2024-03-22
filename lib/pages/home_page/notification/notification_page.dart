import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_your_q/pages/home_page/notification/components/notification_likes/notification_likes.dart';
import 'package:share_your_q/pages/home_page/notification/components/notification_others/notification_others.dart';
import 'package:share_your_q/pages/home_page/notification/components/riverpod/tab_notifier.dart';

import 'package:share_your_q/utils/various.dart';
//TODO Admob
import "package:share_your_q/admob/inline_adaptive_banner.dart";

//google_admob
//TODO ビルドリリースの時のみ
//import 'package:share_your_q/admob/inline_adaptive_banner.dart';


class NotificationPage extends ConsumerWidget{
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref){

    void showHelp(){
      //ここにはダイアログの形でヘルプを表示する
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("通知"),
            content: Text(
              "お知らせはお問い合わせへの返事などが表示されます。"
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                child: Text("OK")
              )
            ],
          );
        }
      );

    }


    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            //ヘルプマーク
            IconButton(
              onPressed: showHelp, 
              icon: Icon(Icons.help_outline)
            )
          ],
          
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("通知"),
            ],
          ),
          
        ),
        body: Column(
          children: [


            TabBar(
                tabs: [
                  Tab(text: "いいね "),
                  Tab(text: "お知らせ "),
                ],
                onTap: (index) {
                  ref.read(tabNotifierProvider.notifier).updateState(index);
                },
              ),



            Expanded(
              child: TabBarView(
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

            SizedBox(
            height: SizeConfig.blockSizeVertical! * 2,
          ),


          Container(
            height: SizeConfig.blockSizeVertical! * 10,
            color: Colors.white,
            //TODO Admob
            /*
            
             */
            child: InlineAdaptiveAdBanner(
              requestId: "NOTIFICATION", 
              adHeight: SizeConfig.blockSizeVertical!.toInt() * 10,
            ),
          ),


            
          ],
        ),
      ),
    );

    
  }

}