import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_your_q/pages/home_page/home_page_web.dart';
import 'package:share_your_q/pages/login_relatives/login_page.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:async';


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

   @override
  void initState() {
    super.initState();

    bool haveNavigated = false;
    //ここで認証のリッスンを行うsessionがあるならhomepageに移動
    _authSubscription =
        supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && !haveNavigated) {
        haveNavigated = true;
        Navigator.of(context)
            .pushReplacement(HomePage.route());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    //認証の監視をキャンセル
    _authSubscription.cancel();
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

      showLoadingDialog(context, "登録中...");
      //https://supabase.com/docs/guides/getting-started/tutorials/with-flutter?platform=android
      await supabase.auth.signUp(
          email: email, 
          password: password, 
          data: {'username': username , 'locale': locale.toString()/* */},
          emailRedirectTo: 'io.supabase.shareimage://login',
        );
      
      if(mounted){
        Navigator.of(context).pop();
      }
        

      if (!mounted) return;
      context.showSuccessSnackBar(message: 'メールを送りました。認証を行ってください');
      //Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);

    } on AuthException catch (error) {
      if (!mounted) return;
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      if (!mounted) return;
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }


  @override
  Widget build(BuildContext context) {
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
                final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                if (!isValid) {
                  return '3~24文字のアルファベットか文字で入力してください';
                }
                return null;
              },
            ),

            formSpacer,

            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('登録'),
            ),

            formSpacer,
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
