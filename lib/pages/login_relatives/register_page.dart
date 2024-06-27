import 'package:flutter/material.dart';
import 'package:share_your_q/env/env.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_your_q/pages/home_page/home_page_web.dart';
import 'package:share_your_q/pages/login_relatives/login_page.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import 'package:google_sign_in/google_sign_in.dart';

//https://zenn.dev/dshukertjr/books/flutter-supabase-chat/viewer/page1


class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key,required this.isRegistering}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

  final bool isRegistering;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _isLoading = false;

  //formのvalidationに使用
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  late final StreamSubscription<AuthState> _authSubscription;
  final locale = WidgetsBinding.instance.platformDispatcher.locale;

  //TODO Google Auth
  @override
  void initState() {


    super.initState();

    bool haveNavigated = false;
    //ここで認証のリッスンを行うsessionがあるならhomepageに移動
    /*
    
    
     */
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {

      final session = data.session;
      if (session != null && !haveNavigated) {
        haveNavigated = true;
        Navigator.of(context).pushReplacement(HomePage.route());
      }

    });
    
    

    _setupAuthListener();



  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {

        Navigator.of(context).pushReplacement(HomePage.route());

      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    //認証の監視をキャンセル
    _authSubscription.cancel();
  }



  Future<void> _googleSignIn() async {

    /// TODO: update the Web client ID with your own.
    final webClientId = Env.g3;

    /// TODO: update the iOS client ID with your own.
    //const iosClientId = 'my-ios.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      //clientId: iosClientId,
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    await supabase.auth.signInWithIdToken(
      //provider: OAuthProvider.google,
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }


  


  Future<void> _signUp() async {
    //これでformのvalidationを確認
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;

    try {

      showLoadingDialog(context, "送信中...");
      //https://supabase.com/docs/guides/getting-started/tutorials/with-flutter?platform=android
      await supabase.auth.signUp(
          email: email, 
          password: password, 
          data: {'name': username , 'locale': locale.toString()/* */},
          emailRedirectTo: 'io.supabase.shareimage://login',
        );
      
      if(mounted){
        Navigator.of(context).pop();
      }
        

      if (!mounted) return;

      //TODO メールを送信した後の処理
      //Dialogを出す。

      showDialog(
        context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
              
            title: const Text("メールを送信しました。"),
            content: const Text("メールを確認して認証を行ってください。"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );


      //
      //
      //context.showSuccessSnackBar(message: 'メールを送りました。認証を行ってください');
      //Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);

    } on AuthException catch (error) {
      if(mounted){
        Navigator.of(context).pop();
      }
      if (!mounted) return;
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      if(mounted){
        Navigator.of(context).pop();
      }
      if (!mounted) return;
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('登録'),
      ),
      body: Form(

        key: _formKey,

        child: ListView(
          padding: formPadding,
          children: [

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                label: Text('メールアドレス'),
              ),

              validator: (val) {
                if (val == null || val.isEmpty) {
                  return '必須';
                }
                final isValid = EmailValidator.validate(val);
                if (!isValid) {
                  return '不正なEmailアドレスです';
                }
                return null;
              },

              keyboardType: TextInputType.emailAddress,
            ),

            formSpacer,

            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('パスワード'),
              ),

              validator: (val) {
                if (val == null || val.isEmpty) {
                  return '必須';
                }
                if (val.length < 6) {
                  return '6文字以上';
                }
                return null;
              },

            ),

            formSpacer,

            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Text('ユーザー名'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return '必須';
                }
                final isValid = RegExp(r'^.{3,24}$').hasMatch(val);
                if (!isValid) {
                  return '3~24文字で入力してください';
                }
                return null;
              },
            ),

            formSpacer,

            //ここに利用規約とプライバシーポリシーのリンクを追加する
            Align(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  children: <TextSpan>[
                    TextSpan(
                      text: '利用規約',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // 利用規約のURLを開く
                          final url = Uri.parse(Env.u3);
                          launchUrl(url);
                          
                        },
                    ),
              
                    TextSpan(
                      text: 'と',
                    ),
              
                    TextSpan(
                      text: 'プライバシーポリシー',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          final url = Uri.parse(Env.u1);
                          // プライバシーポリシーのURLを開く
                          launchUrl(url);
                        },
                    ),
                    TextSpan(text: 'に同意して登録。'),
              
                    
                  ],
                ),
              ),
            ),


            formSpacer,

            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('登録'),
            ),

            formSpacer,

            ElevatedButton(
              //背景色を変えたい
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Image.asset("assets/images/google-symbol.png", width: 24, height: 24),

                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 5,),
                  const Text('Login with Google'),
                ],
              ),

              onPressed: _isLoading ? null : () async {
                try {
                  await _googleSignIn();
                } on PostgrestException catch (e) {
                  if(context.mounted){
                    context.showErrorSnackBar(message: e.message);
                  }
                } catch (e) {
                  if(context.mounted){
                    context.showErrorSnackBar(message: unexpectedErrorMessage);
                  }
                }
              },
            ),

            
            TextButton(
              onPressed: () {
                Navigator.of(context).push(LoginPage.route());
              },
              child: const Text('すでにアカウントをお持ちの方はこちら'),
            )
          ],
        ),
      ),
    );
  }
}
