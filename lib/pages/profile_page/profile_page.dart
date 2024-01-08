import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:share_your_q/image_operations/image_request.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_display.dart';

import 'package:share_your_q/pages/display_page/display_page.dart';

import 'package:share_your_q/graphs/radar_chart_test1.dart';
import 'package:share_your_q/pages/profile_page/components/profile.dart';
import 'package:share_your_q/pages/profile_page/components/settings/profile_setting.dart';
import 'package:share_your_q/pages/profile_page/components/settings/icon_setting.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:share_your_q/image_operations/image_list_display.dart";


//TODO ここにプロフィールページを作成する
//グラフなどで自分の問題の傾向を見れるようにする

class ProfilePage extends StatefulWidget {

  final String userId;
  final String userName;
  final String? profileImage;

  const ProfilePage({
    Key? key,
    required this.userId,
    required this.userName,
    required this.profileImage,
  }): super(key: key);
  
  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> imageData = [];

  Uint8List? profileImageBytes = Uint8List(0);
  String profileId = "";

  String userName ="";
  int selectedYear = 2000;
  String explainText = "";
  List<dynamic> linkText = [];

  Future<void> getInfoFromSupabase() async{
    try{

      final profileData = await supabase.from("profiles").select<List<Map<String, dynamic>>>().eq("id", widget.userId);

      setState(() {
        profileId = profileData[0]["profile_image_id"];
        userName = profileData[0]["username"];
        selectedYear = profileData[0]["age"];
        explainText = profileData[0]["explain"];

        if (profileData[0]["links"] == null){
        }
        else{
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
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
      }
      return ;
    } catch(_){
      if(context.mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return ;
    }

  }


  @override
  void initState() {

    getInfoFromSupabase();
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
              child: Text("プロフィール編集"),
              onPressed: () async {
                //TODO ここにプロフィール編集機能を書く
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileSettings(profileImage: widget.profileImage,)),
                );
              },
            )
            : TextButton(
              child: Text("フォローする"),
              onPressed: () async {
                //TODO ここにフォロー機能を書く
              },  
            )
          ],
        ),
    
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),

              Container(
                width: SizeConfig.blockSizeHorizontal! * 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),

                padding: EdgeInsets.all(10),

                child: ProfileHeader(
                  userName: userName, 
                  explainText: explainText, 
                  age: selectedYear, 
                  linkText: linkText, 
                  profileImageBytes: profileImageBytes,
                ),
              ),

              SizedBox(height: 10,),

              const TabBar(

                tabs: <Widget>[
                  Tab(text: "投稿", icon: Icon(Icons.star)),
                  Tab(text: "傾向", icon: Icon(Icons.create)),
                  Tab(text: "貢献度", icon: Icon(Icons.workspace_premium)),
                  
                ]
              ),

              SizedBox(height: 10,),
              
              Container(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeVertical! * 75,

                child: TabBarView(
                  
                  children: <Widget>[
                      
                    Center(
                      
                      child: Column(
                        children: [
                          SizedBox(height: 10,),

                          Container(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            height: SizeConfig.blockSizeVertical! * 70,
                            child: ImageListDisplay(
                              searchUserId: widget.userId,
                              level: "全て",
                              method: "新着",
                              subject: "全て",
                              tags: [],
                              title: "${userName}の投稿一覧",
                              showAppbar: false,
                            ),
                          ),
                        ]
                      ),
                    ),
                      
                    Center(
                      child: Text("It's rainy here"),
                    ),
                      
                    Center(
                      child: Text("It's sunny here"),
                    ),
                      
                  ],
                      
                ),
              ),
            ],
          ),
        ),
    
      ),
    );


  }
}














class ProfileHeader extends StatelessWidget {

  final String userName;
  final String explainText;
  final int age;
  final Uint8List? profileImageBytes;

  final List<dynamic> linkText;

  const ProfileHeader({
    Key? key,
    required this.userName,
    required this.explainText,
    required this.age,
    required this.linkText,
    required this.profileImageBytes,
  }): super(key: key);


  
  
  @override
  Widget build(BuildContext context) {

    Future<void> _launchURL(String target) async {
    try {
      final targetUrl = target;
      if (await canLaunchUrl(Uri.parse(targetUrl))) {
        await launchUrl(Uri.parse(targetUrl));
      } else {
        context.showErrorSnackBar(message: "リンクを開くことができませんでした。");
      }
    } catch(_){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      return ;
    }
  }
    
    SizeConfig().init(context);

    return Container(
      width: SizeConfig.blockSizeHorizontal! * 92,
      height: SizeConfig.blockSizeVertical! * 40,
      child: SingleChildScrollView(
        child: Column(
          children: [


            Row(
              children: [
                InkWell(
                    onTap: () {
                    },
                    child: CircleAvatar(
                      backgroundImage: profileImageBytes != null && profileImageBytes != Uint8List(0)
                        ? MemoryImage(profileImageBytes!)
                        : NetworkImage(dotenv.get("CLOUDFLARE_IMAGE_URL")) as ImageProvider<Object>?,
                      radius: 20,
                    ),
                  ),

                SizedBox(width: 10,),

                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10,),

            Row(
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    "誕生年: $age",
                    style: TextStyle(
                      fontSize: 14,
                      //fontStyleは薄くしたい
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10,),

            Row(
              children: [
                /*
                const Opacity(
                  opacity: 0.5,
                  child: Text(
                    "リンク:",
                    style: TextStyle(
                      fontSize: 14,
                      //fontStyleは薄くしたい
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                 */
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: linkText.map((linkText) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async{
                            await _launchURL(linkText);
                          },
                          child: Text(
                            linkText,
                            style: const TextStyle(
                              fontSize: 14,
                              // fontStyleは薄くしたい
                              fontStyle: FontStyle.italic,
                              color: Colors.blue, // リンクの色
                              decoration: TextDecoration.underline, // 下線
                            ),
                          ),
                        ),

                        SizedBox(height: 5,),
                      ],
                    );
                  }).toList(),
                ),


                
                
              ],
            ),

            
            //ここには自己紹介などを書く

            Container(
              alignment: Alignment.centerLeft,

              child: Text(
                explainText,
                style: TextStyle(
                  fontSize: 14,
                  //fontStyleは薄くしたい
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
      
          ],
        ),
      )
    );


  }
}



