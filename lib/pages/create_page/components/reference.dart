import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferenceDisplay extends StatefulWidget{

  final List<dynamic> linkText;

  final String? refExplain;

  const ReferenceDisplay({
    Key? key,
    required this.linkText,
    required this.refExplain,
  }) : super(key: key);

  @override
  _ReferenceDisplayState createState() => _ReferenceDisplayState();
}

class _ReferenceDisplayState extends State<ReferenceDisplay>{

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
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Container(
    
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.blockSizeVertical! * 3,),

            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "参考",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            
                  SizedBox(height: SizeConfig.blockSizeVertical! * 3,),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.linkText.asMap().entries.map((entry) {
                      // entry.key がインデックス（0-based）ですので、1を加えて1-basedの参考番号にします。
                      int referenceNumber = entry.key + 1;
            
                      return Column(
                        children: [
                          Row(
                            children: [
            
                              Text("参考$referenceNumber"),
            
                              const SizedBox(width: 5),
                              
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
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 3,),

            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "説明",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
            
                  Text(
                    widget.refExplain != null ? widget.refExplain! : "説明はありません。",
                    style: const TextStyle(
                      fontSize: 14,
                      // fontStyleは薄くしたい
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
             



    
          ],
        ),
    
    
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
