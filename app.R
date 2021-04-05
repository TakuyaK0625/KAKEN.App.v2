# -------------------------------------------------------
# Source
# -------------------------------------------------------

source("global.R", local = TRUE)
source("00_about/ui_about.R", local = TRUE)
source("10_org_summary/ui_org_summary.R", local = TRUE)
source("21_radar_profile/ui_radar_profile.R", local = TRUE)
source("31_project_detail/ui_project_detail.R", local = TRUE)
source("41_network_all/ui_network_all.R", local = TRUE)
source("42_network_researcher/ui_network_researcher.R", local = TRUE)


# -------------------------------------------------------
# User Interface
# -------------------------------------------------------

# レイアウト
ui <- dashboardPage(
    
    dashboardHeader(title = "KAKEN分析アプリ"),
    
    dashboardSidebar(
        
        sidebarMenu(
            menuItem("このアプリについて", icon = icon("info"), tabName = "about"),
            menuItem("機関別採択額・件数等", icon = icon("university"), tabName = "org_summary"),
            menuItem("機関別レーダーチャート", icon = icon("dot-circle"), tabName = "radar_profile"),
            menuItem("審査区分・研究種目別特徴", icon = icon("th-large"), tabName = "project_detail"),
            menuItem("研究者ネットワーク", icon = icon("project-diagram"), 
                     menuSubItem("特定の研究種目・分野", tabName = "network_all"),
                     menuSubItem("特定の研究者", tabName = "network_researcher"))
            )
        
        ),
    
    dashboardBody(
        
        customTheme,
        
        tabItems(
            
            tabItem_about,
            tabItem_org_summary,
            tabItem_project_detail,
            tabItem_radar_profile,
            tabItem_network_all,
            tabItem_network_researcher
            
            )
        )
    )


#--------------------------------------------------------
# Server
#--------------------------------------------------------

server <- function(input, output, session) {
    
    source("10_org_summary/server_org_summary.R", local = TRUE)
    source("00_about/server_about.R", local = TRUE)
    source("21_radar_profile/server_radar_profile.R", local = TRUE)
    source("31_project_detail/server_project_detail.R", local = TRUE)
    source("41_network_all/server_network_all.R", local = TRUE)
    source("42_network_researcher/server_network_researcher.R", local = TRUE)
    
}


#--------------------------------------------------------
# Execution
#--------------------------------------------------------

shinyApp(ui = ui, server = server)
