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

