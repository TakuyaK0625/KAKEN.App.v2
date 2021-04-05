# --------------------
# パッケージ
# --------------------

library(shiny)
library(shinyTree)
library(shinydashboard)
library(shinycssloaders)
library(shinybusy)
library(dashboardthemes)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(DT)
library(plotly)
library(fmsb)
library(wordcloud2)
library(data.table)
library(igraph)
library(threejs)
library(networkD3)
library(echarts4r)
library(future)
library(promises)
library(ipc)



# --------------------
# 備考
# --------------------

source("10_org_summary/remarks_org_summary.R")
source("21_radar_profile/remarks_radar_profile.R")
source("31_project_detail/remarks_project_detail.R")
source("41_network_all/remarks_network_all.R")
source("42_network_researcher/remarks_network_researcher.R")


# -----------------------
# データのインポート
# -----------------------

# 研究種目（全体）
type_all <- read.csv("99_InputData/type_all.csv") %>% .$研究種目 %>% sort

# 研究種目（ネットワーク）
type_net <- read.csv("99_InputData/type_net.csv") %>% .$研究種目 %>% sort

#------------
# 審査区分
kubun <- read.csv("99_InputData/review_section.csv", colClasses = rep("character", 5))

#------------
# 大学名リスト
univ <- read.csv("99_InputData/university.csv", colClasses = "character")

#------------
# 大学グループリスト
univ_group <- read.csv("99_InputData/university_group.csv", colClasses = rep("character", 7))

    
# -----------------
# 審査区分Tree（Empty）
# -----------------

review_list <- list()
for (i in unique(kubun$大区分)) {
    sub_list <- list()
    for(j in (kubun[kubun$大区分 == i, "中区分"])){
        sub <- as.list(rep("", length(kubun[kubun$中区分 == j, 1])))
        names(sub) <- kubun[kubun$中区分 == j, "小区分"]
        sub_list[[j]] <- sub
        }
    review_list[[i]] <- sub_list
    }

review_list <- c(review_list, "")
names(review_list) [12] <- "その他"


# ---------------------------
# 審査区分Tree（All selected）
# ---------------------------

review_list_all <- review_list
for (i in seq_along(review_list_all)) {
    for (j in seq_along(review_list_all[[i]])) {
        for (k in seq_along(review_list_all[[i]][[j]])) {
            attr(review_list_all[[i]][[j]][[k]], "stselected") <- TRUE
        }
    }
}

attr(review_list_all[["その他"]], "stselected") <- TRUE

review_section_all <- c(kubun$大区分, kubun$中区分, kubun$小区分, "その他") %>% unique


# ----------------
# 大学グループ
# ----------------

Group <- list(旧帝大 = univ_group[univ_group$旧帝大 == 1,]$Name,
                 旧六医大 = univ_group[univ_group$旧六医大 == 1,]$Name,
                 新八医大 = univ_group[univ_group$新八医大 == 1,]$Name,
                 NISTEP_G1 = univ_group[univ_group$NISTEP == "G1",]$Name,
                 NISTEP_G2 = univ_group[univ_group$NISTEP == "G2",]$Name,
                 NISTEP_G3 = univ_group[univ_group$NISTEP == "G3",]$Name,
                 国立財務_A = univ_group[univ_group$国立財務 == "A",]$Name,
                 国立財務_B = univ_group[univ_group$国立財務 == "B",]$Name,
                 国立財務_C = univ_group[univ_group$国立財務 == "C",]$Name,
                 国立財務_D = univ_group[univ_group$国立財務 == "D",]$Name,
                 国立財務_E = univ_group[univ_group$国立財務 == "E",]$Name,
                 国立財務_F= univ_group[univ_group$国立財務 == "F",]$Name,
                 国立財務_G = univ_group[univ_group$国立財務 == "G",]$Name,
                 国立財務_H = univ_group[univ_group$国立財務 == "H",]$Name
)

# -----------------------------
# Custom Theme
# -----------------------------

customTheme <- shinyDashboardThemeDIY(
    
    ### general
    appFontFamily = "Arial"
    ,appFontColor = "rgb(0,0,0)"
    ,primaryFontColor = "rgb(0,0,0)"
    ,infoFontColor = "rgb(0,0,0)"
    ,successFontColor = "rgb(0,0,0)"
    ,warningFontColor = "rgb(0,0,0)"
    ,dangerFontColor = "rgb(0,0,0)"
    ,bodyBackColor = "rgb(255,255,255)"
    
    ### header
    ,logoBackColor = "rgb(23,103,124)"
    
    ,headerButtonBackColor = "rgb(238,238,238)"
    ,headerButtonIconColor = "rgb(75,75,75)"
    ,headerButtonBackColorHover = "rgb(210,210,210)"
    ,headerButtonIconColorHover = "rgb(0,0,0)"
    
    ,headerBackColor = "rgb(238,238,238)"
    ,headerBoxShadowColor = "#aaaaaa"
    ,headerBoxShadowSize = "2px 2px 2px"
    
    ### sidebar
    ,sidebarBackColor = cssGradientThreeColors(
        direction = "down"
        ,colorStart = "rgb(20,97,117)"
        ,colorMiddle = "rgb(20,97,117)"
        ,colorEnd = "rgb(20,97,117)"
        ,colorStartPos = 0
        ,colorMiddlePos = 50
        ,colorEndPos = 100
    )
    ,sidebarPadding = 0
    
    ,sidebarMenuBackColor = "transparent"
    ,sidebarMenuPadding = 0
    ,sidebarMenuBorderRadius = 0
    
    ,sidebarShadowRadius = "3px 5px 5px"
    ,sidebarShadowColor = "#aaaaaa"
    
    ,sidebarUserTextColor = "rgb(255,255,255)"
    
    ,sidebarSearchBackColor = "rgb(55,72,80)"
    ,sidebarSearchIconColor = "rgb(153,153,153)"
    ,sidebarSearchBorderColor = "rgb(55,72,80)"
    
    ,sidebarTabTextColor = "rgb(255,255,255)"
    ,sidebarTabTextSize = 13
    ,sidebarTabBorderStyle = "none none solid none"
    ,sidebarTabBorderColor = "rgb(35,106,135)"
    ,sidebarTabBorderWidth = 1
    
    ,sidebarTabBackColorSelected = cssGradientThreeColors(
        direction = "right"
        ,colorStart = "rgba(44,222,235,1)"
        ,colorMiddle = "rgba(44,222,235,1)"
        ,colorEnd = "rgba(44,222,235,1)"
        ,colorStartPos = 0
        ,colorMiddlePos = 30
        ,colorEndPos = 100
    )
    ,sidebarTabTextColorSelected = "rgb(0,0,0)"
    ,sidebarTabRadiusSelected = "0px 0px 0px 0px"
    
    ,sidebarTabBackColorHover = cssGradientThreeColors(
        direction = "right"
        ,colorStart = "rgba(0,255,213,1)"
        ,colorMiddle = "rgba(0,255,213,1)"
        ,colorEnd = "rgba(0,255,213,1)"
        ,colorStartPos = 0
        ,colorMiddlePos = 30
        ,colorEndPos = 100
    )
    ,sidebarTabTextColorHover = "rgb(50,50,50)"
    ,sidebarTabBorderStyleHover = "none none solid none"
    ,sidebarTabBorderColorHover = "rgb(75,126,151)"
    ,sidebarTabBorderWidthHover = 1
    ,sidebarTabRadiusHover = "0px 0px 0px 0px"
    
    ### boxes
    ,boxBackColor = "rgb(255,255,255)"
    ,boxBorderRadius = 0
    ,boxShadowSize = "0px 1px 1px"
    ,boxShadowColor = "rgba(0,0,0,.1)"
    ,boxTitleSize = 16
    ,boxDefaultColor = "rgb(210,214,220)"
    ,boxPrimaryColor = "rgba(44,222,235,1)"
    ,boxInfoColor = "rgb(91,192,222)"
    ,boxSuccessColor = "rgba(92,184,92,1)"
    ,boxWarningColor = "rgb(240,173,78)"
    ,boxDangerColor = "rgb(255,88,55)"
    
    ,tabBoxTabColor = "rgb(255,255,255)"
    ,tabBoxTabTextSize = 14
    ,tabBoxTabTextColor = "rgb(0,0,0)"
    ,tabBoxTabTextColorSelected = "rgb(0,0,0)"
    ,tabBoxBackColor = "rgb(255,255,255)"
    ,tabBoxHighlightColor = "rgba(44,222,235,1)"
    ,tabBoxBorderRadius = 5
    
    ### inputs
    ,buttonBackColor = "rgb(245,245,245)"
    ,buttonTextColor = "rgb(0,0,0)"
    ,buttonBorderColor = "rgb(200,200,200)"
    ,buttonBorderRadius = 5
    
    ,buttonBackColorHover = "rgb(235,235,235)"
    ,buttonTextColorHover = "rgb(100,100,100)"
    ,buttonBorderColorHover = "rgb(200,200,200)"
    
    ,textboxBackColor = "rgb(255,255,255)"
    ,textboxBorderColor = "rgb(200,200,200)"
    ,textboxBorderRadius = 5
    ,textboxBackColorSelect = "rgb(245,245,245)"
    ,textboxBorderColorSelect = "rgb(200,200,200)"
    
    ### tables
    ,tableBackColor = "rgb(255,255,255)"
    ,tableBorderColor = "rgb(240,240,240)"
    ,tableBorderTopSize = 1
    ,tableBorderRowSize = 1
    
)

