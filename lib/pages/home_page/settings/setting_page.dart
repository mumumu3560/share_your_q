import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:share_your_q/env/env.dart';
import 'package:share_your_q/pages/home_page/settings/inquiry/inquiry_page.dart';
import 'package:share_your_q/pages/login_relatives/redirect.dart';

import 'package:share_your_q/utils/various.dart';


import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO Admob
import "package:share_your_q/admob/inline_adaptive_banner.dart";

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



  Future<void> _notificationCheck()async{
    try{

      final response = await supabase
        .from('profiles')
        .select('allow_notification')
        .eq('id', myUserId);

      setState(() {
        isChecked = response[0]['allow_notification'];
      });

      return;

    }
    on PostgrestException catch (e){
      if(mounted){
        context.showErrorSnackBar(message: e.message);
      }

      return;
    }
    catch(e){
      if(mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return;
    }
  }
  Future<void> _switchNotification(bool isChecked) async{

    //TODO 通知の設定を変更する

    if(!isChecked){
      //TODO 通知を受けらない OneSignal
      await OneSignal.logout();
    }
    else{
      //TODO 通知を受ける OneSignal
      
      await OneSignal.login(myUserId);


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
      body: Column(
        children: [
          Expanded(
            child: ListView(
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
                    _launchURL(Env.u3);
                  },
                ),
                ListTile(
                  title: const Text('プライバシーポリシー'),
                  onTap: () {
                    _launchURL(Env.u1);
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
                    
                    
            
                    /*
                    await OneSignal.logout();
            
                    await supabase
                    .from('profiles')
                    .update(
                      {
                        'allow_notification': false
                      }
                    )
                    .eq('id', myUserId);
                     */
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
              requestId: "SETTING", 
              adHeight: SizeConfig.blockSizeVertical!.toInt() * 10,
            ),
          ),


        

        ],
      ),

    );
  }
}