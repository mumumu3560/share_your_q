import 'package:flutter/material.dart';
import 'package:share_your_q/env/env.dart';

import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

import 'package:share_your_q/pages/display_page/display_page.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';

//google_admob
//TODO ビルドリリースの時のみ
import 'package:share_your_q/admob/inline_adaptive_banner.dart';

class ImageListDisplay extends StatefulWidget {
  final String? subject;
  final String? level;
  final String? method;
  final List<String>? tags;
  final String? title;
  final String? searchUserId;

  final bool showAppbar;

  final String lang;

  final bool canToPage;

  final bool add;
  final bool showAdd;

  const ImageListDisplay({
    Key? key,
    required this.subject,
    required this.level,
    required this.method,
    required this.tags,
    required this.title,
    required this.searchUserId,
    required this.showAppbar,
    required this.lang,
    required this.canToPage,
    required this.add,
    required this.showAdd,
  }) : super(key: key);

  @override
  ImageListDisplayState createState() => ImageListDisplayState();
}

class ImageListDisplayState extends State<ImageListDisplay> {
  List<Map<String, dynamic>> imageData = [];
  bool isLoading = true;

  double difficulty = 0;

  List<Map<String, dynamic>> profileImage = [];
  String profileImageId = "";

  ScrollController _scrollController = ScrollController();

  //TODO ビルドリリースの時のみ
  //final AdMob _adMob = AdMob();

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

  Future<void> fetchData() async {
    try {
      final List<Map<String, dynamic>> response;

      //Conditional Chaining
      //https://supabase.com/docs/reference/dart/using-filters
      var query =
          supabase.from("image_data").select();
      if (widget.level != "全て" && widget.level != null) {
        query = query.eq("level", widget.level as String);
      }

      if (widget.subject != "全て" && widget.subject != null) {
        query = query.eq("subject", widget.subject as String);
      }

      if (widget.method == "未発掘") query = query.eq("watched", 0);

      if (widget.searchUserId != "" && widget.searchUserId != null) {
        query = query.eq("user_id", widget.searchUserId as String);
      }

      if (widget.lang != "全て") query = query.eq("lang", widget.lang);

      List<String> tags = [];

      for (var tag in widget.tags!) {
        if (tag == "") continue;
        tags.add(tag);
      }


      //ここでtagを検索する
      for (var tag in tags) {
        if (tag == "") continue;

        //orはその中でどれかに当てはまればいい*はワイルドパターン%と同じ
        //https://supabase.com/docs/reference/dart/or
        //https://postgrest.org/en/stable/references/api/tables_views.html#horizontal-filtering-rows

        query = query.or("tag1.like.*$tag*,"
            "tag2.like.*$tag*,"
            "tag3.like.*$tag*,"
            "tag4.like.*$tag*,"
            "tag5.like.*$tag*");
        //query = query.eq("tag1", tag);
      }

      if (widget.method == "新着") {
        response = await query.order("created_at", ascending: false);
      } else if (widget.method == "いいね順") {
        response = await query.order("likes", ascending: false);
      } else if (widget.method == "ランダム") {
        response = await query.order("created_at", ascending: false);
        response.shuffle();
      } else {
        response = await query.order("created_at", ascending: false);
      }

      setState(() {
        isLoading = false;
        imageData = response;
      });
    } catch (e) {
    }
  }

  // リストをリロードするメソッド
  void reloadList() {
    setState(() {
      isLoading = true;
    });
    fetchData(); // リロード時にデータを再取得
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showAppbar,
        title: Text(widget.title as String), // アプリバーに表示するタイトル
        actions: [
          IconButton(
            onPressed: reloadList,
            icon: const Icon(Icons.refresh), // リロードアイコン
          ),
        ],
      ),
      body: Center(
        child: Container(
          //中央寄り
          alignment: Alignment.center,
          //width: SizeConfig.blockSizeHorizontal! * 90,
          //height: SizeConfig.blockSizeVertical! * 90,

          child: Column(
            children: [
              if (imageData.isEmpty && !isLoading)
                //const Padding(padding: EdgeInsets.all(8.0),),
                //const Center(child: Text("データがありません。"))
                Container(
                  padding: const EdgeInsets.all(8.0),
                    
                    child: const Text(
                      "data is empty",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
              else
                isLoading
                    ? Expanded(
                        child: const Center(child: CircularProgressIndicator()))
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
                            addAutomaticKeepAlives: true,
                            itemCount: imageData.length,
                            //itemCount: 10,
                            itemBuilder: (context, index) {
                              //6の倍数の時には広告を表示する。
                              if (index % 6 == 1) {
                                final item = imageData[index];
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

                                    widget.showAdd
                                      ?SizedBox(
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
                                    )
                                    : const SizedBox(),
                                    //const ,

                                    MyListItem(
                                      item: item,
                                      canToPage: widget.canToPage,
                                    ),
                                  ],
                                );
                              } else {
                                final item = imageData[index];
                                return MyListItem(
                                  item: item,
                                  canToPage: widget.canToPage,
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
class MyListItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool canToPage;

  const MyListItem({
    Key? key,
    required this.item,
    required this.canToPage,
  }) : super(key: key);

  @override
  State<MyListItem> createState() => _MyListItemState();
}

class _MyListItemState extends State<MyListItem>
    with AutomaticKeepAliveClientMixin {
  //TODO mylistitemが保持されているかどうか。
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final String? imageUrlPX = widget.item["problem_id"];
    final String? imageUrlCX = widget.item["comment_id"];

    final String targetUserId = widget.item["user_id"];

    String profileImageId = Env.c3;

    //ここで投稿日時の管理
    String formatCreatedAt(String createdAtString) {

      
      //ここで日本時間に変換する
      //DateTime createdAt = DateTime.parse(createdAtString).add(const Duration(hours: 9));
      DateTime createdAt = DateTime.parse(createdAtString).toLocal();

      /*
      print("createdAtString: $createdAtString");
      print("変換後の");
      print(createdAt);
       */
      DateTime now = DateTime.now().toLocal();
      
      /*
      print("現在時刻");
      print(now);
       */
      Duration difference = now.difference(createdAt);
      /*
      print("差分");
      print(difference);
       */

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

    Future<String> fetchProfileImage(String target) async {
      try {

        final response = await supabase
            .from("profiles")
            .select()
            .eq("id", target);

        if (response[0]["profile_image_id"] == null) {
          return Env.c3;
        } else {
          profileImageId = response[0]["profile_image_id"];
          return response[0]["profile_image_id"];
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

    final List<String> titleLines = widget.item['title'].toString().split("\n");
    final List<String> explainLines =
        widget.item['explain'].toString().split("\n");

    bool isLoadingImage = true;

    return Card(
      child: ListTile(
        dense: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: fetchProfileImage(targetUserId),
              builder: (context, profileImageSnapshot) {
                if (profileImageSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  // データの読み込み中はローディングインジケータなどを表示する
                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: const CircularProgressIndicator()
                  );
                } else if (profileImageSnapshot.hasError ||
                    profileImageSnapshot.data == "") {
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
                      context.showErrorSnackBar(message: "プロフィールに遷移できません");
                    },
                  );
                } else {
                  isLoadingImage = false;
                  // データが正常に読み込まれた場合に画像を表示する
                  return GestureDetector(
                    child: CircleAvatar(
                      radius: 20,
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
                                  
                                  
                              // エラーが発生した場合は代替のアイコンを表示する
                              return const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              );
                            } else {
                              // データが正常に読み込まれた場合に画像を表示
                              return Image.memory(
                                imageSnapshot.data as Uint8List,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  // エラーが発生した場合の代替イメージを表示する
                                  print(imageSnapshot);
                                  print("aaaaaaaaaa");
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
                        if (widget.canToPage) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                userId: widget.item["user_id"],
                                userName: widget.item["user_name"],
                                //profileImage: profileImageId,
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
              width: SizeConfig.blockSizeHorizontal! * 2,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item['user_name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              
                  //Supabaseのtimestamptz型をDateTime型に変換して表示
                  //日本時間に変換。
                  //Text(format(DateTime.parse(widget.item["created_at"]), locale: 'ja')),
                  Text(formatCreatedAt(widget.item["created_at"])),
              
                  widget.item["title"] != null
                      ? titleLines.length > 3
                          ? Text(
                              "${titleLines[0]}\n${titleLines[1]}\n${titleLines[2]}\n……",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ))
                          : Text(
                              "[${widget.item['title']}]",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                      : const Text("タイトルなし"),
              
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 3,
                  ),
              
                  SizedBox(
                    //width: SizeConfig.blockSizeHorizontal! * 65,
                    child: widget.item["explain"] != null
                        ? explainLines.length > 5
                            ? Text(
                                "${titleLines[0]}\n${titleLines[1]}\n${titleLines[2]}\n${titleLines[3]}\n${titleLines[4]}\n……",
                                style: const TextStyle(
                                  fontSize: 15,
                                ))
                            : Text(widget.item["explain"],
                                style: const TextStyle(
                                  fontSize: 15,
                                ))
                        : const Text(
                            "説明文なし",
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
              
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 3,
                  ),
              
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 16,
                          ),
                          Text(widget.item["watched"].toString()),
                          formSpacer,
              
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 16,
                          ),
                          Text(widget.item["likes"].toString()),
                          formSpacer,
              
                          const Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 16,
                          ),
                          Text(widget.item["comments"].toString()),
                          formSpacer,
              
                          const Icon(Icons.thumb_up_alt,
                              color: Colors.green, size: 16),
                          //const Text("Q:"),
                          Text(widget.item["pro_add"].toString()),
                          formSpacer,
              
                          const Icon(
                            Icons.thumb_up_alt,
                            color: Colors.blue,
                            size: 16,
                          ),
                          //const Text("A:"),
                          Text(widget.item["com_add"].toString()),
              
                          /*
                      formSpacer,
              
                      
                       */
                        ],
                      ),
              
                      /*
                  Row(
                    children: [
                      
                      
                    ],
                  ),
                   */
              
                      Row(
                        children: [
                          widget.item["level"] != null
                              ? Text(
                                  widget.item['level'],
                                  style: const TextStyle(fontSize: 12),
                                )
                              : const Text(
                                  "レベルなし",
                                  style: const TextStyle(fontSize: 12),
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          widget.item["subject"] != null
                              ? Text(
                                  widget.item['subject'],
                                  style: const TextStyle(fontSize: 12),
                                )
                              : const Text(
                                  "教科なし",
                                  style: const TextStyle(fontSize: 14),
                                ),
                          const SizedBox(
                            width: 10,
                          ),
              
                          /*
                      widget.item["difficulty_point"] != null && widget.item["eval_num"] != 0
                        ? Text(
                            "${"難易度: " + (widget.item["difficulty_point"]/widget.item["eval_num"]).toDouble().toStringAsFixed(1)}点",
                            style: const TextStyle(
                             fontSize: 12,
                            ),
                          )
                        : const Text("難易度なし", style: const TextStyle(fontSize: 12),),
              
                      const SizedBox(width: 10,),
                      */
                        ],
                      ),
                      Row(children: [
                        if (widget.item['tag1'] != null &&
                            widget.item["tag1"] != "")
                          Text(
                            "#" + widget.item['tag1'],
                            style: TextStyle(fontSize: 12),
                          ),
                        if (widget.item['tag2'] != null &&
                            widget.item["tag2"] != "")
                          Text(
                            "#" + widget.item['tag2'],
                            style: TextStyle(fontSize: 12),
                          ),
                        if (widget.item['tag3'] != null &&
                            widget.item["tag3"] != "")
                          Text(
                            "#" + widget.item['tag3'],
                            style: TextStyle(fontSize: 12),
                          ),
                        if (widget.item['tag4'] != null &&
                            widget.item["tag4"] != "")
                          Text(
                            "#" + widget.item['tag4'],
                            style: TextStyle(fontSize: 12),
                          ),
                        if (widget.item['tag5'] != null &&
                            widget.item["tag5"] != "")
                          Text(
                            "#" + widget.item['tag5'],
                            style: TextStyle(fontSize: 12),
                          ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayPage(
              title: widget.item['title'],

              image_id: widget.item["image_data_id"],
              image_own_user_id: widget.item["user_id"],
              tag1: widget.item['tag1'],
              tag2: widget.item['tag2'],
              tag3: widget.item['tag3'],
              tag4: widget.item['tag4'],
              tag5: widget.item['tag5'],

              //tags: item['tags'],
              level: widget.item['level']!,
              subject: widget.item['subject']!,
              image1: null,
              image2: null,
              imageUrlPX: imageUrlPX,
              imageUrlCX: imageUrlCX,

              num: widget.item['num'],

              explanation: widget.item['explain'],

              problem_id: widget.item["problem_id"],
              comment_id: widget.item["comment_id"],

              watched: widget.item["watched"],

              likes: widget.item["likes"],

              userName: widget.item["user_name"],

              difficulty: widget.item["eval_num"] != 0
                  ? widget.item["difficulty_point"] /
                      widget.item["eval_num"].toDouble()
                  : 0,

              profileImage: profileImageId,

              problemAdd: widget.item["pro_add"],
              commentAdd: widget.item["com_add"],
            ),
          )

              );
        },
      ),
    );
  }
}
