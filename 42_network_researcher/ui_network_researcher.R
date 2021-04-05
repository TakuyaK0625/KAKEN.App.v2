tabItem_network_researcher <- tabItem(tabName = "network_researcher", 
                                      
    # Processing
    add_busy_spinner(spin = "fading-circle"),
                                      
    # 全体レイアウト
    sidebarLayout(
                                          
        # サイドバー
        sidebarPanel(
                                              
            # フィルター適用ボタン
            actionButton("submit_net_researcher", (strong("Apply Filter")), 
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                              
            br(), br(),
                                              
            # 対象年度の指定
            sliderInput("year_net_researcher", "対象年度", min = 2018, max = 2020, sep = "", value = c(2018, 2019)),
                                          
            # 対象の研究者とネットワークの距離を指定 
            fluidRow(
                column(6, textInput("id_net_researcher", "研究者番号")),
                column(6, sliderInput("distance_net_researcher", "距離", min = 1, max = 4, value = 2))
                ),

            # 審査区分チェックボックス
            fluidRow(
                p(strong("審査区分"), style = "float:left; padding-left:15px"),
                actionLink("selectall_area_net_researcher", "　(Select All)"),
                ),
            shinyTree("area_net_researcher", checkbox = TRUE),
                                              
            br(),
                                              
            # 研究種目チェックボックス
            fluidRow(
                p(strong("研究種目"), style = "float:left; padding-left:15px"),
                actionLink("selectall_net_researcher", "　(Select All)")
                ),
            checkboxGroupInput("type_net_researcher", NULL, type_net),
            
            ), #sidebarPanel
                                          
        # メインパネル
        mainPanel(
                                              
            tabsetPanel(
                                                  
                tabPanel("ネットワーク", 
                         br(),                  
                         forceNetworkOutput("net_researcher", height = 700),
                         ),
                
                tabPanel("備考", remarks_network_researcher)

                ) # tabsetPanel
                                              
            ) # mainPanel
                                          
        ) #sidebarLayout
                                      
    ) #tabItem


