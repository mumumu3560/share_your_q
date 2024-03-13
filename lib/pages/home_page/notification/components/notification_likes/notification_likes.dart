import 'package:flutter/material.dart';
import 'package:share_your_q/env/env.dart';
import 'package:share_your_q/pages/display_page/display_page.dart';

import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import 'package:share_your_q/image_operations/image_list_display.dart';

//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';

//google_admob
//TODO ビルドリリースの時のみ
import 'package:share_your_q/admob/inline_adaptive_banner.dart';

class LikesNotificationList extends StatefulWidget {

  const LikesNotificationList({
    Key? key,
  }) : super(key: key);

  @override
  LikesNotificationListState createState() => LikesNotificationListState();
}

class LikesNotificationListState extends State<LikesNotificationList> {
  bool isLoading = true;

  String profileImageId = "";

  List<Map<String, dynamic>> imageData = [];
  List<Map<String, dynamic>> likesUserData = [];

  Future<void> fetchData() async {
    try {
      final response = await supabase
          .from("likes")
          .select<List<Map<String, dynamic>>>("image_id, user_id")
          .eq("image_own_user_id", myUserId)
          .eq("add", true)
          .order("added_at", ascending: false);

      for (int i = 0; i < response.length; i++) {
        if (response[i]["user_id"] == myUserId) {
          continue;
        }

        final response1 = await supabase
            .from("profiles")
            .select<List<Map<String, dynamic>>>(
                "id, username, profile_image_id")
            .eq("id", response[i]["user_id"]);

        final response2 = await supabase
            .from("image_data")
            .select<List<Map<String, dynamic>>>()
            .eq("image_data_id", response[i]["image_id"]);

        // 新たな入れ子構造を作成します。
        Map<String, dynamic> nestedResponse = {
          "profile": response1[0], // "profile" キーの下に response1[0] のデータを格納
          "imageData": response2[0] // "imageData" キーの下に response2[0] のデータを格納
        };

        // nestedResponseをlikesUserDataに追加します。
        likesUserData.add(nestedResponse);
      }

      setState(() {
        likesUserData = likesUserData;
        isLoading = false;
      });
    } on PostgrestException catch (e) {
      print('Error: ${e.message}');
      print('Status code: ${e.code}');
    } catch (e) {
      print("error");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    //TODO ビルドリリースの時のみ
  }

  @override
  void dispose() {
    super.dispose();
    //TODO ビルドリリースの時のみ
  }

  // リストをリロードするメソッド
  Future<void> reloadList() async{
    setState(() {
      isLoading = true;
    });

    await fetchData();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, title: Text("いいね") // アプリバーに表示するタイトル

          ),
      body: Center(
        child: Container(
          //中央寄り
          alignment: Alignment.center,

          child: Column(
            children: [
              if (likesUserData.isEmpty && !isLoading)
                Container(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 10),
                    child: const Text(
                  "data is empty",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ))
              else
                isLoading
                    ? const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                    : Expanded(
                        //RefreshIndicatorによってリロードできるようになる。
                        child: RefreshIndicator(
                          color: Colors.green,
                          onRefresh: () async {
                            reloadList();
                          },

                          //リストビューを作成する
                          //TODOスクロールバーの追加
                          child: ListView.builder(
                            //https://stackoverflow.com/questions/68623174/why-cant-i-slide-the-listview-builder-on-flutter-web
                            physics: const AlwaysScrollableScrollPhysics(),

                            //TODO ここでリストの保持を行う。
                            itemCount: likesUserData.length,
                            //itemCount: 10,
                            itemBuilder: (context, index) {
                              //6の倍数の時には広告を表示する。
                              if (index % 6 == 1) {
                                final imageItem =
                                    likesUserData[index]["imageData"];
                                final profileItem =
                                    likesUserData[index]["profile"];
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
                                          SizeConfig.blockSizeVertical! * 40,
                                      //InlineAdaptiveAdBanner(requestId: "LIST",),
                                      //TODO Admob
                                      /*
                                      //InlineAdaptiveExample(),
                                       */
                                      child: InlineAdaptiveAdBanner(
                                        requestId: "LIST", 
                                        adHeight: SizeConfig.blockSizeVertical!.toInt() * 40,
                                      )
                                    ),
                                    //const ,

                                    LikesNotificationItem(
                                      imageItem: imageItem,
                                      profileItem: profileItem,
                                      canToPage: true,
                                    ),
                                  ],
                                );
                              } else {
                                final imageItem =
                                    likesUserData[index]["imageData"];
                                final profileItem =
                                    likesUserData[index]["profile"];

                                return LikesNotificationItem(
                                  imageItem: imageItem,
                                  profileItem: profileItem,
                                  canToPage: true,
                                );
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
class LikesNotificationItem extends StatefulWidget {
  final Map<String, dynamic> imageItem;
  final Map<String, dynamic> profileItem;
  final bool canToPage;

  const LikesNotificationItem({
    Key? key,
    required this.imageItem,
    required this.profileItem,
    required this.canToPage,
  }) : super(key: key);

  @override
  State<LikesNotificationItem> createState() => _LikesNotificationItemState();
}

class _LikesNotificationItemState extends State<LikesNotificationItem>
    with AutomaticKeepAliveClientMixin {
  //TODO LikesNotificationItemが保持されているかどうか。
  @override
  bool get wantKeepAlive => true;

  bool isLoadingImage = true;

  Future<void> fetchMyProfileImage() async {
    try {
      final response = await supabase
          .from("profiles")
          .select("profile_image_id")
          .eq("id", myUserId);

      myProfileImageId = response[0]["profile_image_id"];

      print("ここがあああああああああああああああああmyProfileImageId");
      print(myProfileImageId);

      setState(() {
        myProfileImageId = myProfileImageId;
      });
    } on PostgrestException catch (error) {
      if (context.mounted) {
        context.showErrorSnackBar(message: error.message);
      }
      return;
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return;
    }
  }

  Future<String> fetchProfileImage() async {
    try {
      print("widget.profileItem['profile_image_id']の中身");
      print(widget.profileItem["profile_image_id"]);

      if (widget.profileItem["profile_image_id"] == null) {
        print("ここはダメな方ですプロフィールの");
        likesUserImageId = Env.c3;
        return Env.c3;
      } else {
        print("ここはいい方ですプロフィールの");
        likesUserImageId = widget.profileItem["profile_image_id"];
        print(likesUserImageId);
        //return likesUserImageId;
        return widget.profileItem["profile_image_id"];
      }
    } on PostgrestException catch (error) {
      if (context.mounted) {
        context.showErrorSnackBar(message: error.message);
      }
      return Env.c3;
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return Env.c3;
    }
  }

  late String imageUrlPX;
  late String imageUrlCX;

  late String targetUserId;

  late String myProfileImageId;
  late String likesUserImageId;

  late final List<String>? titleLines;
  late final List<String>? explainLines;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    imageUrlPX = widget.imageItem["problem_id"];
    imageUrlCX = widget.imageItem["comment_id"];

    targetUserId = widget.imageItem["user_id"];

    myProfileImageId = Env.c3;

    fetchMyProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<String> titleLines = widget.imageItem['title'].toString().split("\n");
    List<String> explainLines =
        widget.imageItem['explain'].toString().split("\n");

    return Card(
      child: ListTile(
        dense: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: fetchProfileImage(),
              builder: (context, profileImageSnapshot) {
                print("profileImageSnapshotの中身");
                print(profileImageSnapshot.data);
                if (profileImageSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  // データの読み込み中はローディングインジケータなどを表示する
                  return const CircularProgressIndicator();
                } else if (profileImageSnapshot.hasError ||
                    profileImageSnapshot.data == "") {
                  // エラーが発生した場合は代替のアイコンを表示する
                  return GestureDetector(
                    child: const CircleAvatar(
                      radius: 16,
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
                      radius: 16,
                      child: ClipOval(
                        child: FutureBuilder(
                          future: fetchImageWithCache(
                              profileImageSnapshot.data as String),
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              // データの読み込み中はローディングインジケータなどを表示する
                              return const CircularProgressIndicator();
                            } else if (imageSnapshot.hasError ||
                                imageSnapshot.data == null) {
                              print("ここかもしれないなぁ");
                              // エラーが発生した場合は代替のアイコンを表示する
                              return const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 32,
                              );
                            } else {
                              // データが正常に読み込まれた場合に画像を表示する
                              print("ここは最後の砦です");
                              print(profileImageSnapshot.data);
                              return Image.memory(
                                imageSnapshot.data as Uint8List,
                                fit: BoxFit.cover,
                                width: 32,
                                height: 32,
                                errorBuilder: (context, error, stackTrace) {
                                  print("ここは最後のエラーとアンって");
                                  // エラーが発生した場合の代替イメージを表示する
                                  return const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 32,
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
                        if (widget.canToPage) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                userId: widget.profileItem["id"],
                                userName: widget.profileItem["username"],
                                profileImage: likesUserImageId,
                              ),
                            ),
                          );
                        }
                      } else {
                        context.showErrorSnackBar(message: "現在読み込み中です...");
                      }
                    },
                  );
                }
              },
            ),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 1,
            ),
            Text(
              widget.profileItem['username'] + "さんからいいねされました",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                //背景が黒に合う色、水色か緑色を使いたい。
                color: Color.fromARGB(255, 99, 236, 99),
              ),
            ),
            SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 2,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                widget.imageItem["title"] != null
                    ? titleLines.length > 3
                        ? Text(
                            "${titleLines[0]}\n${titleLines[1]}\n${titleLines[2]}\n……",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ))
                        : Text(
                            "[${widget.imageItem['title']}]",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                    : const Text("タイトルなし"),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 3,
                ),
                widget.imageItem["explain"] != null
                    ? explainLines.length > 5
                        ? Text(
                            "${titleLines[0]}\n${titleLines[1]}\n${titleLines[2]}\n${titleLines[3]}\n${titleLines[4]}\n……",
                            style: const TextStyle(
                              fontSize: 15,
                            ))
                        : Text(widget.imageItem["explain"],
                            style: const TextStyle(
                              fontSize: 15,
                            ))
                    : const Text(
                        "説明文なし",
                        style: const TextStyle(fontSize: 16),
                      ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 3,
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayPage(
              title: widget.imageItem['title'],

              image_id: widget.imageItem["image_data_id"],
              image_own_user_id: widget.imageItem["user_id"],
              tag1: widget.imageItem['tag1'],
              tag2: widget.imageItem['tag2'],
              tag3: widget.imageItem['tag3'],
              tag4: widget.imageItem['tag4'],
              tag5: widget.imageItem['tag5'],

              //tags: item['tags'],
              level: widget.imageItem['level']!,
              subject: widget.imageItem['subject']!,
              image1: null,
              image2: null,
              imageUrlPX: imageUrlPX,
              imageUrlCX: imageUrlCX,

              num: widget.imageItem['num'],

              explanation: widget.imageItem['explain'],

              problem_id: widget.imageItem["problem_id"],
              comment_id: widget.imageItem["comment_id"],

              watched: widget.imageItem["watched"],

              likes: widget.imageItem["likes"],

              userName: widget.imageItem["user_name"],

              difficulty: widget.imageItem["eval_num"] != 0
                  ? widget.imageItem["difficulty_point"] /
                      widget.imageItem["eval_num"].toDouble()
                  : 0,

              profileImage: myProfileImageId,

              problemAdd: widget.imageItem["pro_add"],
              commentAdd: widget.imageItem["com_add"],
            ),
          ));
        },
      ),
    );
  }
}
