tabItem_about <- tabItem(tabName = "about",
    
    br(),
    
    fluidRow(
        
        column(7, 
               
               h3(strong("はじめに")),
               p("このアプリはKAKENデータベースからダウンロードできる採択課題データ（csv形式）を用いた科研費分析ツールです。
                開発の目的としては、機関別の特徴や審査区分別の特徴、研究種目別の特徴等をざっくりとでも掴めるようにすることを
                目指しています。まだまだ開発途上ですので、何か不具合等ございましたら遠慮なくご連絡ください。また、他の分析の
                観点等のリクエストも大歓迎です。なお、このアプリの利用にあたっては以下の点にご留意ください。"),
               
               br(),
               
               tags$ul(
                   tags$li("分析の正確さには注意しているつもりですが、あくまで個人プロジェクトですので、参考までにご活用ください。"),
                   tags$li("デザインや機能等は予告なく変更することがありますので予めご了承ください。"), 
                   tags$li("サーバーの利用時間に制限があるため、利用状況によってはアクセスできない場合があります。")
                ),
                            
               br(),
               
               h4(strong("更新履歴")),
               dataTableOutput("update_DT"),
               
               ), # column
                            
        column(5, 
               
               br(),
               
               box(title = p("連絡先", style = "color: white; margin: 0;"), solidHeader = T, status = "info", width = 12,
                   p("信州大学 学術研究・産学官連携推進機構"),
                   p("久保 琢也 助教"),
                   p("E-mail: kubotaku[AT]shinshu-u.ac.jp")
                   ),

               box(title = p("データソース", style = "color: white; margin: 0;"), solidHeader = T, status = "success", width = 12,
                   p("「KAKEN：科学研究費助成事業データベース」より以下の通りデータを取得"),
                   p("【 期 間 】2018年〜2020年度の採択課題"),
                   p("【 対 象 】「採択後辞退」を除く全採択課題"),
                   p("【取得日】2021年3月17日（随時更新）")
                   ),
                            
               box(title = p("謝辞", style = "color: white; margin: 0;"), solidHeader = T, status = "warning", width = 12,
                   p("本取り組みは以下の皆様、助成金の支援を受けて実施しております。この場を借りて御礼申し上げます。"),
                   tags$ul(
                       tags$li("「KAKEN：科学研究費助成事業データベース」を整備されている国立情報学研究所の皆様"),
                       tags$li("開発にあたり有用なコメントやフィードバックをいただいているC4RAの皆様"),
                       tags$li("本取り組みは第49回リバネス研究費「日本の研究.com賞」の支援を受けて実施しています")
                       )
                   )
                            
               ) # column

        ) # fluidRow

    ) # tabItem

