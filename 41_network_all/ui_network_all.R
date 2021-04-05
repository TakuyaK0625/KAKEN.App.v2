tabItem_network_all <- tabItem(tabName = "network_all", 
                               
    # Processing
    add_busy_spinner(spin = "fading-circle"),
                               
    # 全体レイアウト
    sidebarLayout(
                                   
        # サイドバー
        sidebarPanel(
                                       
            # フィルター適用ボタン
            actionButton("submit_network_all", (strong("Apply Filter")), 
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4; float: left"),
#            actionButton("stop_network_all", (strong("STOP")), 
#                         style="color: #fff; background-color: #b3424a; border-color: #9c3a41; margin-left: 10px"),

            br(), br(),
                                       
            # 年度選択スライダー
            sliderInput("year_net_all", "対象年度", min = 2018, max = 2021, sep = "", value = c(2018, 2019)),
                                       
            # ハイライトする研究機関
            selectizeInput("org_net_all", "ハイライト機関", choices = univ$所属機関, multiple = T),
                                       
            br(),
                                       
            # 審査区分チェックボックス
            p(strong("審査区分")),
            shinyTree("area_net_all", checkbox = TRUE),
                                       
            br(),
            
            # 研究種目チェックボックス
            checkboxGroupInput("type_net_all", "研究種目", type_net)
                                       
            ), # sidebarPanel
                                   
        # メインパネル
        mainPanel(
            
            tabsetPanel(
                                           
                tabPanel("ネットワーク",
                         br(),
                         scatterplotThreeOutput("network_all", height = 500),
                         br(), br(), br(), br(),
                         h3(strong("中心性指標")),
                         dataTableOutput("centrality")
                         ),
                                           
                tabPanel("備考", remarks_network_all)
                                           
                ) # tabsetPanel
                                       
            ) # mainPanel
                                   
        ) # sidebarLayout
                               
    ) # tabItem


