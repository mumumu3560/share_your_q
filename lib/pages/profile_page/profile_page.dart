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
  String linkText = "";

  Future<void> getInfoFromSupabase() async{
    try{

      final profileData = await supabase.from("profiles").select<List<Map<String, dynamic>>>().eq("id", widget.userId);

      setState(() {
        profileId = profileData[0]["profile_image_id"];
        userName = profileData[0]["username"];
        selectedYear = profileData[0]["age"];
        explainText = profileData[0]["explain"];
        linkText = profileData[0]["Links"];
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


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return DefaultTabController(
      length: 3,
      initialIndex: 0,

      child: Scaffold(
    
        appBar: AppBar(
          title: Row(
            children: [
              Column(
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
                  
                ],
              ),
              SizedBox(width: 10,),
              Text('${widget.userName}'),
            ],
          ),

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

          bottom: (
    
            const TabBar(
              tabs: <Widget>[
                Tab(text: "プロフィール", icon: Icon(Icons.star)),
                Tab(text: "作問・解答傾向", icon: Icon(Icons.create)),
                Tab(text: "貢献度", icon: Icon(Icons.workspace_premium)),
                
              ]
            )
          )
          
          //title: const Text("プロフィール"),
        ),
    
        body: TabBarView(
          children: <Widget>[
              
            Center(
              
              child: SingleChildScrollView(

                child: Column(
                  children: [
                    SizedBox(height: SizeConfig.blockSizeVertical!*10,),
                    
                    Container(
                      child: Profile(
                        userId: widget.userId,
                        userName: widget.userName,
                      )
                    ),
                    
                    SizedBox(height: 50,),
                    
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 90,
                      height: SizeConfig.blockSizeVertical! * 80,
                      child: RadarChartSample(),
                    ),
                    
                  ]
                ),
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
    );


  }
}



