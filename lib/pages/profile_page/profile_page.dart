import 'package:flutter/material.dart';
import 'package:share_your_q/env/env.dart';
//import 'package:share_your_q/admob/ad_test.dart';
import 'dart:math';

import 'package:share_your_q/utils/various.dart';


import 'package:share_your_q/pages/profile_page/components/settings/profile_setting.dart';
import 'dart:typed_data';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:share_your_q/image_operations/image_list_display.dart";
import 'package:share_your_q/pages/profile_page/components/create_trend.dart';


import 'package:flutter/gestures.dart';

import 'package:share_your_q/pages/profile_page/components/follow_list/follow_list.dart';

import 'package:share_your_q/pages/profile_page/components/likes/likes_list.dart';

import 'package:share_your_q/pages/display_page/components/appbar_actions/components/comments_list.dart';


//TODO Admob
import 'package:share_your_q/admob/anchored_adaptive_banner.dart';

//TODO ここにプロフィールページを作成する
//グラフなどで自分の問題の傾向を見れるようにする

bool isLoadingAll = true;
bool isLoadingHeader = true;
bool isLoadingPage = true;

class ProfilePage extends StatefulWidget {

  final String userId;
  final String userName;
  //final String? profileImage;

  const ProfilePage({
    Key? key,
    required this.userId,
    required this.userName,
    //required this.profileImage,
  }): super(key: key);
  
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //List<Map<String, dynamic>> imageData = [];

  Uint8List? profileImageBytes = Uint8List(0);
  String? profileId;

  String userName ="";
  int selectedYear = 0;
  String explainText = "";
  List<dynamic> linkText = [];

  Future<void> getInfoFromSupabase() async{
    try{

      final profileData = await supabase.from("profiles").select().eq("id", widget.userId);

      setState(() {
        
        if(profileData[0]["profile_image_id"] != null){
          profileId = profileData[0]["profile_image_id"];
        }

        userName = profileData[0]["username"];
        selectedYear = profileData[0]["age"];
        explainText = profileData[0]["explain"];

        if(profileData[0]["links"] != null){
          linkText = profileData[0]["links"];
        }

        
      });

      fetchImageWithCache(profileId).then((bytes){
        setState(() {
          profileImageBytes = bytes;
        });
      });

      return ;


    } on PostgrestException catch (error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
      return ;
    } catch(_){
      if(mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return ;
    }

  }






  late List<Map<String, dynamic>> _imageData = [];
  Map<DateTime, int>? _heatmapData = {};
  //Map<DateTime, int>? _heatmapData2 = {};

  Map<DateTime, int>? _heatmapDataMath = {};
  Map<DateTime, int>? _heatmapDataPhys = {};
  Map<DateTime, int>? _heatmapDataChemi = {};
  Map<DateTime, int>? _heatmapDataOther = {};

  //ここに投稿した問題の数を入れる。
  int mathStreakSum = 0;
  int physStreakSum = 0;
  int chemiStreakSum = 0;
  int otherStreakSum = 0;

  //ここに現在の連続日数を入れる。
  int mathStreakNow = 0;
  int physStreakNow = 0;
  int chemiStreakNow = 0;
  int otherStreakNow = 0;

  //ここに最長のstreakを入れる。
  int mathStreakMax = 0;
  int physStreakMax = 0;
  int chemiStreakMax = 0;
  int otherStreakMax = 0;

  //
  Map<String, int> streakSums = {};
  Map<String, int> streakNows = {};
  Map<String, int> streakMaxs = {};

  bool isLoading = true;


  int maxSize = 0;

  //List<Map<String, dynamic>>

  List<Map<String,dynamic>> likesData = [];

  
  Future<void> fetchData() async {
    try{
      _imageData = await supabase
        .from('image_data')
        .select()
        .eq('user_id', widget.userId)
        .order('created_at', ascending: true);

      final response = await supabase
        .from("likes")
        .select("image_id")
        .eq("user_id", widget.userId)
        .eq("add", true)
        .order("added_at", ascending: false);


      for(int i = 0; i < response.length; i++){
        final response2 = await supabase
          .from("image_data")
          .select()
          .eq("image_data_id", response[i]["image_id"]);
        
        likesData.add(response2[0]);
      }



      convertData("watched", _imageData);

      setState(() {
        _heatmapData = _heatmapData;
        likesData = likesData;
        
      });

      

      //convertDataSubject("subject", _imageData);


    } on PostgrestException catch (error) {
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
      return ;
    }
    catch (_) {
      if(mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      
      return ;
    }
  }


  

  Future<void> fetchLikes() async{

    try{
      
    }
    on PostgrestException catch (error){
      context.showErrorSnackBar(message: error.message);
    } catch(_){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }

  }

  //ここではheatmapで使えるデータ型に変更する。
  //typeはwatchedかlikesのどちらか
  //targetは_imageDataか_likesDataのどちらか
  void convertData(String type, List<Map<String, dynamic>> target){

    for(int i = 0; i < target.length; i++){

      //utcを日本時間に変換
      DateTime date = DateTime.parse(target[i]["created_at"]).toLocal();

      DateTime truncatedDateTime = DateTime(date.year, date.month, date.day);

      int watchedCount = target[i][type]! as int;
      int watchedCount2 = 0;

      if(_heatmapData![truncatedDateTime] != null){
        watchedCount2 = _heatmapData![truncatedDateTime]!;
      }
      
      int watchedCount3 = watchedCount + watchedCount2;

      _heatmapData![truncatedDateTime] = watchedCount3;//_imageData[i]["watched"]! as int;
      maxSize = max(maxSize, target[i][type]);




      String createdSubject = target[i]["subject"]! as String;
      DateTime oneDayBefore = truncatedDateTime.subtract(Duration(days: 1));

      if(createdSubject == "数学"){
        
        mathStreakSum++;
        _heatmapDataMath![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;


        if(_heatmapDataMath![oneDayBefore] != null){
          mathStreakNow++;
          
        }
        else{
          mathStreakNow = 1;
          
        }

        mathStreakMax = max(mathStreakMax, mathStreakNow);
        

      }
      else if(createdSubject == "物理"){
        physStreakSum++;
        _heatmapDataPhys![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      

        if(_heatmapDataMath![oneDayBefore] != null){
          physStreakNow++;
          

        }
        else{
          physStreakNow = 1;

        }
        physStreakMax = max(physStreakMax, physStreakNow);

      
      }
      else if(createdSubject == "化学"){
        chemiStreakSum++;
        _heatmapDataChemi![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;



        if(_heatmapDataMath![oneDayBefore] != null){
          chemiStreakNow++;
          

        }
        else{
          chemiStreakNow = 1;
        }
        chemiStreakMax = max(chemiStreakMax, chemiStreakNow);


      }
      else{
        otherStreakSum++;
        _heatmapDataOther![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;


        if(_heatmapDataMath![oneDayBefore] != null){
          otherStreakNow++;

        }
        else{
          otherStreakNow = 1;
        }

        otherStreakMax = max(otherStreakMax, otherStreakNow);

      }

    }

    //
    DateTime now = DateTime.now();
    DateTime truncatedNow = DateTime(now.year, now.month, now.day);


    if(_heatmapDataMath![truncatedNow] == null){
      mathStreakNow = 0;
    }
    if(_heatmapDataPhys![truncatedNow] == null){
      physStreakNow = 0;
    }
    if(_heatmapDataChemi![truncatedNow] == null){
      chemiStreakNow = 0;
    }
    if(_heatmapDataOther![truncatedNow] == null){
      otherStreakNow = 0;
    }

    streakSums["数学"] = mathStreakSum;
    streakSums["物理"] = physStreakSum;
    streakSums["化学"] = chemiStreakSum;
    streakSums["その他"] = otherStreakSum;

    streakNows["数学"] = mathStreakNow;
    streakNows["物理"] = physStreakNow;
    streakNows["化学"] = chemiStreakNow;
    streakNows["その他"] = otherStreakNow;

    streakMaxs["数学"] = mathStreakMax;
    streakMaxs["物理"] = physStreakMax;
    streakMaxs["化学"] = chemiStreakMax;
    streakMaxs["その他"] = otherStreakMax;


    

    
  }



  //ここはfollow関係
  List<Map<String,dynamic>> followData = [];
  List<Map<String,dynamic>> followerData = [];

  int followNum = 0;
  int followedNum = 0;
  
  Future<void> fetchFollow()async{

    try{

      //followed_idはフォローされている人のid
      //follower_idはフォローしている人のid

      followerData = await supabase
        .from("follow")
        .select()
        .eq("followed_id", widget.userId)
        .eq("add", true);

      followData = await supabase
        .from("follow")
        .select()
        .eq("follower_id", widget.userId)
        .eq("add", true);

      
      setState(() {
        followNum = followData.length;
        followedNum = followerData.length;
      });

      

    }
    on PostgrestException catch (error){

      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
      
      return ;
    }
    catch(_){
      if(mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      
      return ;
    }
      
  }


  bool? isFollowed;
  String myUsername = "";

  Future<void> isFollow() async{
    try{

      final response = await supabase
        .from('follow')
        .select()
        .eq('follower_id', myUserId)
        .eq('followed_id', widget.userId);

      final res = await supabase 
        .from("profiles")
        .select()
        .eq("id", myUserId);

      myUsername = res[0]["username"];
      
      if(response.isEmpty){

        await supabase
          .from("follow")
          .insert([
            {
              "follower_id" : myUserId,
              "followed_id" : widget.userId,
              "add": false,
              "follower_name" : myUsername,
            }
          ]);

        setState(() {
          isFollowed = false;
        });

      }
      else{
        if(response[0]["add"] == true){
          setState(() {
            isFollowed = true;
          });
        }
        else{
          setState(() {
            isFollowed = false;
          });
        }
      }

    } on PostgrestException catch (error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
      return;
    } catch(_){
      if(mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return;
    }
  } 
  
  
  Future<void> waitProcess() async{
    await getInfoFromSupabase();
    await fetchData();

    await fetchFollow();
    if(myUserId != widget.userId){
      await isFollow();
    }

    setState(() {
      isLoading = false;
      isLoadingPage = false;
    });

    if(isLoadingHeader == false){
      setState(() {
        isLoadingAll = false;
      });
    }
  }

  @override
  void initState() {

    /*
    getInfoFromSupabase();
    fetchData();
     */

    waitProcess();


    //fetchLikes();



    super.initState();
  }

  /*
  length: 3,
      initialIndex: 0,
   */


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return DefaultTabController(
      length: 3,
      initialIndex: 0,

      child: Scaffold(
    
        appBar: AppBar(

          actions: [
            widget.userId == myUserId
            ? TextButton(
              child: const Text("プロフィール編集"),
              onPressed: () async {
                //TODO ここにプロフィール編集機能を書く
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileSettings(profileImage: profileImageBytes/*widget.profileImage */,)),
                );
              },
            )
            : const SizedBox(width: 10,),

            /*
            TextButton(
              child: const Text("フォローする"),
              onPressed: () async {
                //TODO ここにフォロー機能を書く
              },  
            )
             */
          ],
        ),
    
        body: isLoading
        ? const Center(child: CircularProgressIndicator(),)
        :Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
            
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 100,
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
           
            
                      //padding: const EdgeInsets.all(10),
            
                      child: ProfileHeader(
                        userName: userName, 
                        explainText: explainText, 
                        age: selectedYear, 
                        linkText: linkText, 
                        profileImageBytes: profileImageBytes,
                        userId: widget.userId,

                        isFollowed: isFollowed == null ? false : isFollowed!,
                        followData: followData,
                        followerData: followerData,
                        followNum: followNum,
                        followedNum: followedNum,


                      ),
                    ),
            
                    const SizedBox(height: 10,),
            
                    const TabBar(
           
            
                      tabs: <Widget>[
                        Tab(text: "投稿", /*icon: Icon(Icons.star) */),
                        Tab(text: "傾向", /*icon: Icon(Icons.create) */),
                        Tab(text: "いいね", ),
                        //Tab(text: "貢献度", /*icon: Icon(Icons.workspace_premium) */),
                        
                      ]
                    ),
            
                    const SizedBox(height: 10,),
                    
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 90,
                      height: SizeConfig.blockSizeVertical! * 60,

                  
            
                      child: TabBarView(
                        
                        children: <Widget>[
                          
                          //ここに投稿一覧を表示する
                          Center(
                            
                            child: Column(
                              children: [
                                const SizedBox(height: 10,),
            
                                SizedBox(
                                  //width: SizeConfig.blockSizeHorizontal! * 90,
                                  height: SizeConfig.blockSizeVertical! * 55,
                                  child: ImageListDisplay(
                                    searchUserId: widget.userId,
                                    level: "全て",
                                    method: "新着",
                                    subject: "全て",
                                    tags: const [],
                                    title: "投稿一覧",
                                    showAppbar: false,
                                    lang: "全て",
                                    canToPage: false,
                                    add: false,
                                    showAdd: false,
                                  ),
                                ),
                              ]
                            ),
                          ),
                          

                          //ここに傾向を表示する(Heatmapなど)
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 10,),
            
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 100,
                                  height: SizeConfig.blockSizeVertical! * 55,

                                  child: CreateTrend(
                                    image_own_user_id: widget.userId,
                                    heatmapData: _heatmapData,
                                    maxSize: maxSize,
                                    heatmapDataMath: _heatmapDataMath,
                                    heatmapDataPhys: _heatmapDataPhys,
                                    heatmapDataChemi: _heatmapDataChemi,
                                    heatmapDataOther: _heatmapDataOther,

                                    streakSums: streakSums,
                                    streakNows: streakNows,
                                    streakMaxs: streakMaxs,
                                  ),
                                ),
                              ]
                            ),
                          ),
                          
                          //ここはいいね
                          Center(

                            /*
                            
                             */
                            child: SizedBox(
                              height: SizeConfig.blockSizeVertical! * 55,
                              child: LikesList(
                                likesData: likesData,
                                userId: widget.userId,
                              ),
                            )

                            //child: Text("aaaaaaa")
                          ),

                            
                        ],
                            
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 3,),
            
            Container(
              height: SizeConfig.blockSizeVertical! * 10,
              color: Colors.white,
              //TODO Admob
              child: AdaptiveAdBanner(requestId: "PROFILE"),
            ),
            //BannerContainer(height: SizeConfig.blockSizeHorizontal! * 10,)
            //InlineAdaptiveExample(),
          ],
        ),
    
      ),
    );


  }
}


















class ProfileHeader extends StatefulWidget {

  final String userName;
  final String explainText;
  final int age;
  final Uint8List? profileImageBytes;

  final List<dynamic> linkText;
  final String userId;

  final bool isFollowed;

  final List<Map<String,dynamic>> followData;
  final List<Map<String,dynamic>> followerData;

  final int followNum;
  final int followedNum;

  const ProfileHeader({
    Key? key,
    required this.userName,
    required this.explainText,
    required this.age,
    required this.linkText,
    required this.profileImageBytes,
    required this.userId,

    required this.isFollowed,

    required this.followData,
    required this.followerData,

    required this.followNum,
    required this.followedNum,
    

  }): super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {



  bool isFollowNow = false;

  Future<void> followProcess() async{
    try{

      if(widget.isFollowed == true){

        await supabase
          .from('follow')
          .update({ "add": false })
          .eq('follower_id', myUserId)
          .eq('followed_id', widget.userId);

        
        setState(() {
          isFollowNow = false;
        });
      }
      else if(isFollowNow == false){

        await supabase
          .from('follow')
          .update({ "add": true })
          .eq('follower_id', myUserId)
          .eq('followed_id', widget.userId);

        setState(() {
          isFollowNow = true;
        });

      }


    } on PostgrestException catch (error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
    } catch(_){
      if(mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      isFollowNow = widget.isFollowed;
    });


    //waitProcess();
  }

  Future<void> _launchURL(String target) async {
    try {
      final targetUrl = target;
      if (await canLaunchUrl(Uri.parse(targetUrl))) {
        await launchUrl(Uri.parse(targetUrl));
      } else {
        if(mounted){
          context.showErrorSnackBar(message: "リンクを開くことができませんでした。");
        }
      }
    } catch(_){
      if(mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return ;
    }
  }


  @override
  Widget build(BuildContext context) {

    
    
    SizeConfig().init(context);

    return Container(
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          InkWell(
              onTap: () {
              },
              child: CircleAvatar(
                backgroundImage: widget.profileImageBytes != null && widget.profileImageBytes != Uint8List(0)
                  ? MemoryImage(widget.profileImageBytes!)
                  : NetworkImage(Env.c1) as ImageProvider<Object>?,
                radius: 20,
              ),
            ),
          
          const SizedBox(height: 10,),
          
          Text(
            "${widget.userName}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10,),

          widget.userId == myUserId || isFollowNow == null
            ? const SizedBox(width: 10,)
            : ElevatedButton(

              style: ElevatedButton.styleFrom(
                //フォローしていないときは透明にしたい
                backgroundColor: isFollowNow == false ? Colors.blue : Colors.red,
                //もうすこしまるみを持たせたい
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                
              ),
              onPressed: () async {
                //フォローする
                await followProcess();
              },
              child: isFollowNow == false
                ? const Text("フォローする", style:TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                : const Text("フォロー解除", style:TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),

          const SizedBox(height: 10,),

          Row(
            children: [
              Opacity(
                opacity: 0.5,
                child: Text(
                  widget.age == 0
                    ? "誕生年:非公開"
                    : "誕生年:${widget.age}",
                  style: const TextStyle(
                    fontSize: 14,
                    //fontStyleは薄くしたい
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10,),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            /*
            children: widget.linkText.map((linkText) {
              return Column(
                children: [
                  /*
                  InkWell(
                    onTap: () async{
                      await _launchURL(linkText);
                    },
                    child: Text(
                      "$linkText ",
                      style: const TextStyle(
                        fontSize: 14,
                        // fontStyleは薄くしたい
                        fontStyle: FontStyle.italic,
                        color: Colors.blue, // リンクの色
                        decoration: TextDecoration.underline, // 下線
                      ),
                    ),
                  ),
                   */


                  
          
                  const SizedBox(height: 5,),
                ],
              );
            }).toList(),
             */
            


            children: widget.linkText.asMap().entries.map((entry) {
              return Column(
                children: [
                  InkWell(
                    /*
                    onTap: () async {
                      //await _launchURL(entry.value);
                    },
                     */
                    child: Text(
                      entry.value,
                    ).urlToLink(context),
                  ),
                  const SizedBox(height: 5),
                ],
              );
            }).toList(),
          ),

          
          //ここには自己紹介などを書く

          Container(
            alignment: Alignment.centerLeft,

            child: Text(
              "${widget.explainText}",
              style: const TextStyle(
                fontSize: 14,
                //fontStyleは薄くしたい
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          //フォロー、フォロワーの数を表示する

          const SizedBox(height: 10,),

          Container(
            child: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    //TODO ここにプロフィール編集機能を書く
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FollowList(
                        followData: widget.followData,
                        userId: widget.userId,
                        //profileImage: widget.profileImageBytes,
                        isFollow: true,
                      )),
                    );
                  },
                  child: Text("フォロー数: ${widget.followNum}"),
                ),

                const SizedBox(width: 10,),
                TextButton(
                  onPressed: () async {
                    //TODO ここにプロフィール編集機能を書く
                    /*
                    
                     */
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FollowList(
                        followData: widget.followerData,
                        userId: widget.userId,
                        //profileImage: widget.profileImageBytes,
                        isFollow: false,
                      )),
                    );
                  },
                  child: Text("フォロワー数: ${widget.followedNum}")
                ),
              ],
            ),
          ),
      
        ],
      )
    );


  }
}





//https://qiita.com/Hiiisan/items/f0bbc5715fab7e6787ad
RegExp _urlReg = RegExp(
  r'https?://([\w-]+\.)+[\w-]+(/[\w-./?%&=#]*)?',
);

extension TextEx on Text {

  RichText urlToLink(
    BuildContext context,
  ) {
    final textSpans = <InlineSpan>[];

    data!.splitMapJoin(
      _urlReg,
      onMatch: (Match matchPre) {
        final match = matchPre[0] ?? '';
        textSpans.add(
          TextSpan(
            text: match,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async => await launchUrl(
                    Uri.parse(match),
                  ),
          ),
        );
        return '';
      },
      onNonMatch: (String text) {
        textSpans.add(
          TextSpan(
            text: text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        );
        return '';
      },
    );

    return RichText(text: TextSpan(children: textSpans));
  }
}