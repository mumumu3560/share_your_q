import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart';


/// チャットのメッセージを表示するためのウィジェット
class ChatBubble extends StatelessWidget {

  final Map<String, dynamic> commentData;
  
  const ChatBubble({
    Key? key,
    required this.commentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
            const SizedBox(width: 12),
            GestureDetector(

              child: CircleAvatar(
                radius: 20,
                child: Image.network("https://storage.divcurious.com/rufy.png"),
                /*
                child: Icon(
                  Icons.error_outline,
                  color: Colors.blue,
                  size: 40,
                ),
                 */

              ),

              onTap: () async{
                //profilepageに飛ぶ

              },


            ),


            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commentData["user_name"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectionArea(
                    child: Text(
                      commentData["comments"],
                      style: TextStyle(
                        fontSize: 14,
                      ),
                  
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(format(DateTime.parse(commentData["created_at"]), locale: 'ja')),
             // 時間を表示
            const SizedBox(width: 60),
        ],
      ),
    );
  }
}