import 'package:flutter/material.dart';
import 'package:share_your_q/env/env.dart';

//import "package:google_fonts/google_fonts.dart";

import 'package:share_your_q/pages/login_relatives/redirect.dart';

//Supabase
import 'package:supabase_flutter/supabase_flutter.dart';


//OneSignal
//TODO
import 'package:onesignal_flutter/onesignal_flutter.dart';


import 'package:timeago/timeago.dart' as timeago;

// TODO google_admob

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //TODO ここはandroidビルドリリースの時のみ
  //MobileAds.instance.initialize();

  //TODO ここはandroidビルドリリースの時のみ
  //OneSignal.initialize(Env.o1);

  //OneSignal.Notifications.requestPermission(true);
  
  

  timeago.setLocaleMessages("ja", timeago.JaMessages());



  await Supabase.initialize(
    // TODO: ここにSupabaseのURLとAnon Keyを入力

    url: Env.s1,
    anonKey: Env.s2,
  );

  /*
  
   */


  

  

  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'タイトル',
      theme: ThemeData.dark().copyWith( 

        primaryColor: Colors.white,
        



   
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),

      ),
      home: const SplashPage(), 
    );
  }

  
}
