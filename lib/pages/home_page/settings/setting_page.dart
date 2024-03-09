import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:share_your_q/pages/home_page/settings/inquiry/inquiry_page.dart';
import 'package:share_your_q/pages/login_relatives/redirect.dart';
import 'package:share_your_q/pages/profile_page/components/iroiro_test/image_test.dart';
//import 'package:share_your_q/admob/ad_test.dart';
import 'dart:math';

import 'package:share_your_q/utils/various.dart';


import 'package:share_your_q/pages/profile_page/components/settings/profile_setting.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:share_your_q/image_operations/image_list_display.dart";
import 'package:share_your_q/pages/profile_page/components/create_trend.dart';


import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:share_your_q/pages/profile_page/components/follow_list/follow_list.dart';

import 'package:share_your_q/pages/profile_page/components/likes/likes_list.dart';

import 'package:share_your_q/pages/display_page/components/appbar_actions/components/comments_list.dart';


class SettingPage extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
  
   

}

class SettingPageState extends State<SettingPage> {

  //ここでOneSignalの通知の切り替えを行う

  bool isChecked = false;


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



  Future<void> _notificationCheck()async{
    try{

      final response = await supabase
        .from('profiles')
        .select<List<Map<String,dynamic>>>('allow_notification')
        .eq('id', myUserId);

      setState(() {
        isChecked = response[0]['allow_notification'];
      });

    }
    on PostgrestException catch (e){
      print(e);
    }
    catch(e){
      print(e);
    }
  }
  Future<void> _switchNotification(bool isChecked) async{
    //TODO 通知の設定を変更する

    if(isChecked){
      //TODO 通知を受けらない OneSignal
      //await OneSignal.logout();
    }
    else{
      //TODO 通知を受ける OneSignal
      
      //await OneSignal.login(myUserId);

    }

    final response = await supabase
        .from('profiles')
        .update(
          {
            'allow_notification': isChecked
          }
        )
        .eq('id', myUserId);

    setState(() {
      isChecked = isChecked;
    });


  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _notificationCheck();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('通知を受け取る'),
            trailing: Switch(
              value: isChecked,
              onChanged: (bool value) {
                setState(() {
                  isChecked = value;
                  _switchNotification(isChecked);
                });
              },
            ),
            onTap: () {
              setState(() {
                isChecked = !isChecked;
                _switchNotification(isChecked);
              });
            },
          ),
          ListTile(
            title: const Text('利用規約'),
            onTap: () {
              _launchURL(dotenv.get("termsUrlJa"));
            },
          ),
          ListTile(
            title: const Text('プライバシーポリシー'),
            onTap: () {
              _launchURL(dotenv.get("privacyUrlJa"));
            },
          ),
          ListTile(
            title: const Text('お問い合わせ'),
            onTap: () {
              if(context.mounted){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InquiryPage()),
                );
              }
            },
          ),
          ListTile(
            title: const Text('ログアウト'),
            onTap: () async{
              
              
              await supabase.auth.signOut();

              //元に戻れないようにページ遷移を行う。

              if(context.mounted){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashPage()),
                  (_) => false,
                );

              }
              

              /*
              MaterialPageRoute( 
                  builder: (context) => SplashPage(),
                ),
               */

              
            },
          ),
        ],
      ),

    );
  }
}