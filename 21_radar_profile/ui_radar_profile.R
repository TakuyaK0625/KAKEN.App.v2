tabItem_radar_profile <- tabItem(tabName = "radar_profile",
                                 
    # Processing
    add_busy_spinner(spin = "fading-circle"),
                                 
    # 全体レイアウト
    sidebarLayout(
                                     
        # サイドバー
        sidebarPanel(
                                         
            # Submitボタン
            actionButton("submit_radar_profile", (strong("Apply Filter")), 
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                         
            br(), br(), 
                                         
            # 年度の指定
            sliderInput("year_radar_profile", "対象年度", min = 2018, max = 2020, sep = "", value = c(2018, 2019)),
                                         
            # 研究機関の選択
            selectizeInput("org_radar_profile", "機関名（最大３機関）", univ$所属機関, multiple = T, options = list(maxItems = 3)),
                                         
            br(),
                                         
            # 指標のタイプの選択
            selectInput("index_radar_profile", "指標", choices = c("件数", "総額"))
                                         
            ), # sidebarPanel
                                     
        # メインパネル
        mainPanel(
                                         
            tabsetPanel(type = "tabs",
                                                     
                        tabPanel("総計",                            
                                 br(),                      
                                 h3(strong("中区分")),
                                 echarts4rOutput("radar_total_m", height = 600),
                                 h3(strong("大区分")),
                                 echarts4rOutput("radar_total_l", height = 600)
                                 ),
                        
                        tabPanel("年次推移", 
                                 br(),
                                 fluidRow(
                                     column(10, 
                                            h3(strong("中区分 "), style = "float:left"), 
                                            p("（※選択した最初の研究機関のみ）", style = "padding:25px")
                                            )
                                     ),
                                 echarts4rOutput("radar_year_m", height = 600),
                                 fluidRow(
                                     column(10, 
                                            h3(strong("大区分 "), style = "float:left"), 
                                            p("（※選択した最初の研究機関のみ）", style = "padding:25px")
                                            )
                                     ),
                                 echarts4rOutput("radar_year_l", height = 600)
                                 ),
                                                     
                        tabPanel("備考", remarks_radar)
                                                     
                        )　# tabsetPanel
                                         
            ) # mainPanel
                                     
        ) # sidebarLayout
                                 
    ) # tabItem
