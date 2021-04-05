tabItem_org_summary <- tabItem(tabName = "org_summary", 
    
    # Processing
    add_busy_spinner(spin = "fading-circle"),
                               
    # 全体レイアウト
    sidebarLayout(
                                   
        # サイドバー
        sidebarPanel(
                                       
            # フィルター適用ボタン
            actionButton("submit_org_summary", (strong("Apply Filter")), 
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                 
            br(), br(),
                                 
            # 研究機関、年次の指定
            fluidRow(
                column(6, selectInput("group_org_summary", "グループ", choices = c("---", "全機関", names(Group)))),
                column(6, sliderInput("year_org_summary", "対象年度", min = 2018, max = 2021, sep = "", value = c(2018, 2019))),
                column(12, selectizeInput("add_org_summary", "任意の機関", univ$所属機関, multiple = T))
                ),
                                       
            # 審査区分チェックボックス
            fluidRow(
                p(strong("審査区分"), style = "float:left; padding-left:15px"),
                actionLink("selectall_area_summary", "　(Select All)"),
                ),
            shinyTree("area_org_summary", checkbox = TRUE),

            br(), br(),
                                       
            # 研究種目チェックボックス
            fluidRow(
                p(strong("研究種目"), style = "float:left; padding-left:15px"),
                actionLink("selectall_org_summary", "　(Select All)")
                ),
            checkboxGroupInput("type_org_summary", NULL, type_all),
            
            ), # sidebarPanel
                                   
        # メインパネル
        mainPanel(
                                       
            tabsetPanel(type = "tabs",
                                                   
                        tabPanel("総計",
                                 
                                 br(),
                                 
                                 fluidRow(
                                     column(3, h2(strong("Barplot"))),
                                     column(3, selectInput("bar_y_org_total", "Y軸の値", choices = list("総額", "件数"))),
                                     column(3, sliderInput("bar_n_org_total", "表示件数", min = 0, max = 50, value = 10, step = 1))
                                     ),
                                 echarts4rOutput("bar_org_total", height = 500),
                                 h2(strong("Summary Table")),
                                 br(),
                                 dataTableOutput("table_org_total"),
                                 downloadButton("download_org_total", "Download")
                                 ),
                                                   
                        tabPanel("年次推移",  
                                 br(),
                                 fluidRow(
                                     column(3, h2(strong("Lineplot"))),
                                     column(3, selectInput("line_y_org_year", "Y軸の値", choices = list("総額", "件数"))),
                                     column(3, sliderInput("line_n_org_year", "表示件数", min = 0, max = 20, value = 10, step = 1))
                                     ),
                                 echarts4rOutput("line_org_year", height = 500),
                                 h2(strong("Summary Table")),
                                 br(),
                                 dataTableOutput("table_org_year"),
                                 downloadButton("download_org_year", "Download")
                                 ),
                                                   
                        tabPanel("備考", remarks_org_summary)
                                                   
                        ) # tabsetPanel
                                       
            ) # mainPanel
                                   
        ) # sidebarLayout
                               
    ) # tabItem
                

