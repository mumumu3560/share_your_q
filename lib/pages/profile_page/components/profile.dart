import 'package:flutter/material.dart';

import 'package:share_your_q/utils/various.dart';


import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';


class Profile extends StatefulWidget {

  final String userId;
  final String userName;

  const Profile({
    Key? key,
    required this.userId,
    required this.userName,
  }): super(key: key);
  
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Map<String, dynamic>> imageData = [];
  List<Map<String, dynamic>> profileData = [];


  Future<void> fetchData() async{

    try{
      imageData = await supabase
        .from('image_data')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', widget.userId);

      profileData = await supabase
        .from('profiles')
        .select<List<Map<String, dynamic>>>()
        .eq('id', widget.userId);

    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);

    }
    catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);

    }

  }

  @override
  initState(){
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(

      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: SizeConfig.safeBlockHorizontal! * 85,
                  height: SizeConfig.safeBlockVertical! * 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

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
