// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
//import 'package:share_your_q/pages/chat_page.dart';
import 'package:share_your_q/pages/login_relatives/register_page.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/pages/home_page/home_page_web.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // widgetがmountするのを待つ
    await Future.delayed(Duration.zero);

    //ログインしている→ホーム画面へ
    //ログインしていない→ログイン画面へ
    if (!mounted) {
      return;
    }
    final session = supabase.auth.currentSession;
    if (session == null) {
      //falseで前のページに戻れないようにする
      Navigator.of(context).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);
      //Navigator.of(context).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}












