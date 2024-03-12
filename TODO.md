# TODO
## ここには思いついたこと、やることなどを書く。

### Githubみたいなやつ追加したいheatmap
名前がよくわからなかった→contributions calendarというらしい。       
flutter contributions calendar とかでググるとどうやらheatmapのライブラリはあるようだ
https://pub.dev/packages/flutter_heatmap_calendar
これを使うこととする。

具体的には閲覧、addの多さで色分けすればいいと思った。今のところ一日一回のつもりなので問題ごとに分けられるかな。

### 参考文献リンクなどの追加
create_pageの方で参考文献を追加する項目を追加。最大でも10個ほど？       
それに伴ってdisplay_pageの方でもそれを表示するところが必要で、それはappbarのactionsの部分に追加する。

displayの方でlinkは見れるようになった。理解が足りていないかも。     
create_pageのpreviewでもこれが見れるようにしたい。


### admobをどうするか？
自分が今使おうとしているもの
1, バナー
2, インタースティシャル

1
バナーの方はadaptiveの方がいいらしいのでこれをどう使うかを考える

2
インタースティシャルはdialogで使えばいい？何かしらのアクションが終わったことを表すときに同時に示すようにすればよさそう？
場所は作成の終わったときとローディングの時(create_page)、報告のとき(display_page)
https://developers.google.com/search/docs/appearance/avoid-intrusive-interstitials?hl=ja

admobについてだが、今はとりあえずテストデバイスを追加したので本番と同じようなことができる。それでいったん試してみたい。今のままだとテストバナー？だからかわからないがバナーが固定されていて、アダプティブバナーになっていない気がする


###
1/28 TODOを更新する。
今やりたいことを書き出す。

おおまかに完了した。
1: display_pageで、問題、解説の横にグッドボタンを追加したい。     
次にいいねと同様に数を管理、SQLで


いらない2: いいねボタンはアニメーション付けたい↓        
https://qiita.com/Ratdotl/items/91f9561d1c09d226eee1    

保留3: 問題作成の時のインタースティシャル広告周りどうしよう？

完了4: PageViewのローディングを無くしたい。
完了5: ListViewに関しても広告を何度も読み込むのは面倒

6: 言語設定。

7: セキュリティ

1を先にやる。

完了 8: いいねの管理について、これはappbar→problemViewにした方がよさそう。

9: 閲覧履歴を見れるようにしたい。フォロー見れるようにしたい。
→likesの方を見る。displayされるさいにそこが更新されることを確認
→profileから見れるようにする？いいねも

10: 投稿できる問題の制限をつけたい。
→subject周りの制限をSQLでつけた(subjectは数物化その他のみ)      
年月日を比較して、一致→だめ。一日違う→科目が異なればいい。それ以外ならおk
→変更。一日の中で、数,物,化,その他,の4種類は被りがなければ投稿してよい、

また、それに合わせてcreate_trendを作る。(数物化→赤青緑で分ける？青赤緑)
→デバッグでは思いがadbを作ったやつは軽い。

保留 11: ページ遷移→微妙なのでやめておく


12: 画像の全画面表示
→https://qiita.com/ling350181/items/adfebd6f7c648084d1b5
これを参考にする。
またステータスバーやナビゲーションバーを消すようにしたい

13: フォロー機能の実装→多分ok
13: フォローフォロワーを確認(Listで)

222222

やること

1, コメントをListViewの形にする。

2, CloudflareでSupabaseのテーブルを監視

5, プライバシーポリシー


Iconの方での問題。
更新できるのは自分の列だけ
profiles更新→image取得→返却→
profile_image_idはuniqueなのでおｋ

Cloudflare Image周りはできた。



1, OneSignalの通知
2, コメント周り
3, settingpage

4, アイコンの移動と、問い合わせフォーム

5, comment機能の最終実装
