tabItem_project_detail <- tabItem(tabName = "project_detail",
                                  
    # Processing
    add_busy_spinner(spin = "fading-circle"),
                                  
    # 全体レイアウト
    sidebarLayout(
                                      
        # サイドバー
        sidebarPanel(
                                          
            # フィルター適用ボタン
            actionButton("submit_project_detail", (strong("Apply Filter")), 
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                          
            br(), br(),
                                          
            # 年度と研究機関の指定
            fluidRow(
                column(6, sliderInput("year_project_detail", "対象年度", min = 2018, max = 2021, sep = "", value = c(2018, 2019))),
                column(6, selectInput("group_project_detail", "グループ", choices = c("全機関", names(Group))))
                ),
                                          
            # 審査区分の指定
            fluidRow(
                p(strong("審査区分"), style = "float:left; padding-left:15px"),
                actionLink("selectall_area_project_detail", "　(Select All)"),
                ),
            shinyTree("area_project_detail", checkbox = TRUE),

            br(), br(),
                                          
            # 研究種目の選択
            fluidRow(
                p(strong("研究種目"), style = "float:left; padding-left:15px"),
                actionLink("selectall_project_detail", "　(Select All)")
                ),
            checkboxGroupInput("type_project_detail", NULL, type_all)
            
            ), # sidebarPanel
                                      
        # メインパネル
        mainPanel(
                                          
            tabsetPanel(type = "tabs",
                                    
                        tabPanel("職位",
                                 br(),
                                 h3(strong("Barplot（件数）")),
                                 echarts4rOutput("jobtitle_count", height = 500),
                                 h3(strong("Barplot（割合）")),
                                 echarts4rOutput("jobtitle_ratio", height = 500),
                                 h3(strong("Summary Table")),
                                 dataTableOutput("jobtitle_DT")
                                 ),
                                                      
                        tabPanel("研究期間",
                                 br(),
                                 h3(strong("Boxplot")),
                                 echarts4rOutput("years", height = 500),
                                 h3(strong("Summary Table")),
                                 dataTableOutput("year_DT")
                                 ),
                                                      
                        tabPanel("直接経費総額",
                                 br(),
                                 h3(strong("Boxplot")),
                                 echarts4rOutput("directcost", height = 500),
                                 h3(strong("Summary Table")),
                                 dataTableOutput("directcost_DT")
                                 ),
                                                      
                        tabPanel("研究分担者数",
                                 br(),
                                 h3(strong("Boxplot")),
                                 echarts4rOutput("buntan", height = 500),
                                 h3(strong("Summary Table")),
                                 dataTableOutput("buntan_DT")
                                 ),
                                                      
                        tabPanel("キーワード",
                                 br(),
                                 h3(strong("Word Cloud")),
                                 br(),
                                 wordcloud2Output("keyword_cloud"),
                                 br(),
                                 h3(strong("Summary Table")),
                                 dataTableOutput("keyword_table")
                                 ),
                        
                        tabPanel("備考", remarks_project_detail)
                                 
                                                      
                        ) # tabsetPanel
                               
            ) # mainPanel
                                      
        ) # sidebarLayout
                                  
    ) # tabItem

