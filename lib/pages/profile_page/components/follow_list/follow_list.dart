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

class FollowList extends StatefulWidget {

  final String userId;

  final List<Map<String,dynamic>> followData;

  final bool isFollow;


  const FollowList({
    Key? key,
    required this.userId,

    required this.followData,

    required this.isFollow,

  }) :super(key: key);

  @override
  FollowListState createState() => FollowListState();

}


class FollowListState extends State<FollowList> {
  bool isLoading = true;


  List<Map<String, dynamic>> profileImage = [];
  String profileImageId = "";


  
  @override
  void initState() {
    super.initState();

    isLoading = false;


    //TODO ビルドリリースの時のみ
  }

  @override
  void dispose() {
    super.dispose();
    //TODO ビルドリリースの時のみ
  }

  


  // リストをリロードするメソッド
  void reloadList() {
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: widget.isFollow ? Text("フォロー") : Text("フォロワー")  // アプリバーに表示するタイトル

      ),
      body: Center(
        child: Container(
          //中央寄り
          alignment: Alignment.center,
          
          child: Column(
            children: [

              if(widget.followData.isEmpty && !isLoading)
                Container(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 10),
                  child: const Text(
                    "data is empty",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                )

              else 
                isLoading
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator()
                        )
                      )
                    : Expanded(
                      
                      //RefreshIndicatorによってリロードできるようになる。
                        child: RefreshIndicator(
                          color: Colors.green,
                          onRefresh: () async{ 
                            reloadList();
                          },

                          //リストビューを作成する
                          //TODOスクロールバーの追加
                          child: ListView.builder(
                            //https://stackoverflow.com/questions/68623174/why-cant-i-slide-the-listview-builder-on-flutter-web
                            physics: const AlwaysScrollableScrollPhysics(),
                            
                            
                            //TODO ここでリストの保持を行う。
                            itemCount: widget.followData.length,
                            //itemCount: 10,
                            itemBuilder: (context, index) {
                                                
                              //6の倍数の時には広告を表示する。
                              if(index%6 == 1){
                                final item = widget.followData[index];
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
                                      height: SizeConfig.blockSizeVertical! * 40,
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
                                                
                                    
                                    widget.isFollow ? MyListItem(item: item, isFollow: true,) : MyListItem(item: item, isFollow: false,),
                                  ],
                                );
                              }
                              else{
                                final item = widget.followData[index];
                                return widget.isFollow ? MyListItem(item: item, isFollow: true,) : MyListItem(item: item, isFollow: false,);
                              }
                              
                              
                            },
                          ),
                        ),
                      ),
              
            ],
          ),
        ),
      ),
    );
  }
}












//ここはsupabaseから取得したデータの内容を表示するためのウィジェット
class MyListItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isFollow;
  const MyListItem({

    Key? key,
    required this.item,
    required this.isFollow,
    
  }): super(key: key);

  @override
  State<MyListItem> createState() => _MyListItemState();
}

class _MyListItemState extends State<MyListItem> {

  String targetUserId = "";
  String targetUserId2 = "";
  String profileImageId = dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
  String explainText = "";
  String userName = "";

  Future<void> fetchUserProfile(String target) async{
    try{
      final response = await supabase
        .from("profiles")
        .select()
        .eq("id", target);
      
      setState(() {
        userName = response[0]["username"];
        explainText = response[0]["explain"];
      });
    } on PostgrestException catch (error){
      context.showErrorSnackBar(message: error.message);
    } catch(_){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  Future<String> fetchProfileImage(String target) async{

    try{

      final response = await supabase
        .from("profiles")
        .select<List<Map<String, dynamic>>>()
        .eq("id", target);

      if(response[0]["profile_image_id"] == null){

        return dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
      }
      else{
        profileImageId = response[0]["profile_image_id"];
        return response[0]["profile_image_id"];
      }

      //print(profileImageId);

      //return response[0]["profile_image_id"];

    } on PostgrestException catch (error){
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
        
      }
      return dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
    } catch(_){
      if(context.mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
        
      }
      return dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
    }


  }

  bool isLoadingImage = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.isFollow){
      targetUserId = widget.item["followed_id"];
    }
    else{ 
      targetUserId = widget.item["follower_id"];
    }

    

    

    //fetchProfileImage(targetUserId);

    fetchUserProfile(targetUserId);

    print(userName);
    print(explainText);
  }
  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        dense: true,

        leading: FutureBuilder(
          future: fetchProfileImage(targetUserId),
          builder: (context, profileImageSnapshot) {
            if (profileImageSnapshot.connectionState == ConnectionState.waiting) {
              // データの読み込み中はローディングインジケータなどを表示する
              return const CircularProgressIndicator();
            } else if (profileImageSnapshot.hasError || profileImageSnapshot.data == "") {
              // エラーが発生した場合は代替のアイコンを表示する
              return GestureDetector(
                child: const CircleAvatar(
                  radius: 20,
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                onTap: () {
                  print('エラーが発生しました。onTap アクションをここで処理してください。');
                  context.showErrorSnackBar(message: "プロフィールに遷移できません");
                },
              );
            } else {
              print(targetUserId);
              isLoadingImage = false;
              // データが正常に読み込まれた場合に画像を表示する
              return GestureDetector(
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: FutureBuilder(
                      future: fetchImageWithCache(profileImageSnapshot.data as String),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState == ConnectionState.waiting) {
                          // データの読み込み中はローディングインジケータなどを表示する
                          return const CircularProgressIndicator();
                        } else if (imageSnapshot.hasError || imageSnapshot.data == null) {
                          print("ここかもしれないなぁ");
                          // エラーが発生した場合は代替のアイコンを表示する
                          return const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          );
                        } else {
                          // データが正常に読み込まれた場合に画像を表示する
                          print("ここは最後の砦です");
                          print(profileImageSnapshot.data);
                          return Image.memory(
                            imageSnapshot.data as Uint8List,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              print("ここは最後のエラーとアンって");
                              // エラーが発生した場合の代替イメージを表示する
                              return const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
                onTap: () {
                  if (!isLoadingImage) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          userId: widget.isFollow ? widget.item["followed_id"] : widget.item["follower_id"], 
                          userName: userName, 
                          profileImage: profileImageId,
                        ),
                      ),
                    );
                  } else {
                    context.showErrorSnackBar(message: "現在読み込み中です...");
                  }
                },
              );
            }
          },
        ),






        title: Text(
          userName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              explainText,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),

          ],
        ),
        onTap: () async{
          
          
          Navigator.of(context).push(
            MaterialPageRoute(

              builder: (context) => ProfilePage(
                userId: widget.isFollow ? widget.item["followed_id"] : widget.item["follower_id"], 
                userName: userName, 
                profileImage: profileImageId,
              ),
            )

          );
           
        },
      ),
    );
  }
}
