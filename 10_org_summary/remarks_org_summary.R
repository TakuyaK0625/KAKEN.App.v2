remarks_org_summary <- tagList(

    br(),
    
    h4(strong("はじめに")),
    
    p("このページでは研究代表者の所属機関単位で年度を跨いだ各種の集計/可視化ができるようになっています。プリセットしてある特定のグループ内で複数機関を比較することができますが、そこに任意の機関を加えることも可能です。"),
    
    br(),
    
    h4(strong("使い方")),
    tags$ul(
        tags$li("集計対象の研究機関や期間（年度）、審査区分、研究種目を選び、「Apply Filter」ボタンを押すとグラフと集計表が表示されます"),
        tags$li("グラフは棒グラフと折れ線グラフを用意していますが、上部のタブ（「総計」、「年次推移」）で切り替えることができます"),
        tags$li("どちらのグラフもY軸の値（「総額」、「件数」）を変えたり、表示する研究機関数を変えることができます"),
        tags$li("凡例の特定の値（棒グラフの場合は研究種目）をクリックすることで、その値を集計から取り除くことができます（改めてクリックすると復元可能）")
    ),
    
    br(),
    
    h4(strong("研究機関について")),
    tags$ul(
        tags$li("「国立大学法人」や、「独立行政法人」のような法人種別は削除しています。"),
        tags$li("転職等により研究代表者の所属機関が複数にまたがる場合には、最も古い所属機関を用いて集計しています。"),
        tags$li("研究機関グループは以下の文献、サイトを参考にしています。"),
        tags$ul(
            br(),
            tags$li("【旧帝大】"),
            p("https://ja.wikipedia.org/wiki/旧帝大", style = "padding-left: 1.5em; font-size: 0.9em; margin: 0"),
            tags$li("【旧六医大】"),
            p("https://ja.wikipedia.org/wiki/旧六医大", style = "padding-left: 1.5em; font-size: 0.9em; margin: 0"),
            tags$li("【新八医大】"),
            p("https://ja.wikipedia.org/wiki/新八医大", style = "padding-left: 1.5em; font-size: 0.9em; margin: 0"),
            tags$li("【NISTEP_G1~G3】"),
            p("村上昭義、伊神正貫「科学研究のベンチマーキング 2019」, NISTEP RESEARCH MATERIAL, No.284, 文部科学省科学技術・学術政策研究所（http://doi.org/10.15108/rm284）", style = "font-size: 0.8em; margin: 0; padding-left: 1.5em;"),
            tags$li("【国立財務_A~H】"),
            p("https://www.mext.go.jp/b_menu/shingi/kokuritu/sonota/06030714.htm", style = "padding-left: 1.5em; font-size: 0.9em; margin: 0"),
            
        )
    )
    
    )