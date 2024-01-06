import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

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
              

              child: ClipOval(
                child: CircleAvatar(
                  radius: 20,
                  //dotenv.get('SUPABASE_URL'),
                  child: Image.network(dotenv.get("CLOUDFLARE_IMAGE_URL")),
              
                ),
              ),

              onTap: () async{
                //profilepageに飛ぶ

              },


            ),


            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      commentData["user_name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      format
                      (
                        DateTime.parse(commentData["created_at"]), 
                        locale: 'ja'
                      ),
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
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
                      softWrap: true,
                                    
                    ),
                  ),
                ),
              ],
            ),
            
        ],
      ),
    );
  }
}