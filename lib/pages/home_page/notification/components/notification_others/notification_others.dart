import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_your_q/pages/home_page/notification/components/riverpod/supabase/notification_list_supabase.dart';
import 'package:share_your_q/pages/home_page/settings/inquiry/inquiry_page.dart';
import "package:share_your_q/utils/various.dart";


class OtherNotificationList extends ConsumerWidget {
  const OtherNotificationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    

    final otherList = ref.watch(notificationListSupabaseProvider);

    final widget = otherList.when(
      loading:() => const CircularProgressIndicator(),
      error: (error, stack) => const Text("エラーが発生しました"),
      data: (data) => data.isEmpty 
        ? const Text("お知らせはありません") 
        : ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              if(index % 6 == 1){
                return Column(
                  children: [
                    /*
                    Container(
                      height: 64,
                      width: double.infinity,
                      color: Colors.white,
                      //TODO ビルドリリースの時のみ
                      //child: _adMob.getAdBanner(),
                    ),
                      */

                    SizedBox(
                      height:
                          SizeConfig.blockSizeVertical! * 20,
                      //InlineAdaptiveAdBanner(requestId: "LIST",),
                      //TODO Admob
                      /*
                      child: InlineAdaptiveAdBanner(
                        requestId: "LIST", 
                        adHeight: SizeConfig.blockSizeVertical!.toInt() * 40,
                      )//InlineAdaptiveExample(),
                        */
                    ),
                    //const ,
                    OtherNotificationListItem(
                      title: item["contents"],
                      createdAt: item["created_at"],
                    ),
                  ],
                );
              }
              else{
                return OtherNotificationListItem(
                      title: item["contents"],
                      createdAt: item["created_at"],
                    );

              }
            },
          ),

    );

    final refreshIcon = IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        ref.read(notificationListSupabaseProvider.notifier).updateState();
      },
    );


    return Scaffold(
      appBar: AppBar(
        title: const Text("お知らせ"),
        actions: [
          refreshIcon,
        ],
      ),
      body: Container(
        child: widget,
      ),
    );
  }
}




class OtherNotificationListItem extends StatelessWidget {

  const OtherNotificationListItem({
    Key? key,
    required this.title,
    required this.createdAt,
  }) : super(key: key);

  final String title;
  final String createdAt;

  //ここで投稿日時の管理
    String formatCreatedAt(String createdAtString) {
      DateTime createdAt = DateTime.parse(createdAtString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(createdAt);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}時間前';
      } else if (difference.inDays < 365) {
        return '${createdAt.month}月${createdAt.day}日';
      } else {
        return '${createdAt.year}年${createdAt.month}月${createdAt.day}日';
      }
    }


  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(formatCreatedAt(createdAt)),
          ],
        ),
        onTap: () {
          //お問い合わせページに飛ぶ
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return InquiryPage();
              },
            ),
          );
        },
      ),
    );
  }
}

