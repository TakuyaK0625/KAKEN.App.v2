

# -----------------------
# データインポート
# -----------------------

DF_radar_total <- fread("99_InputData/DF_Radar.csv", 
                        colClasses = list(numeric = c(1, 5), 
                                          character = c(2:4, 6:8)))

# -------------------------------
# 関数作成：区分別の相対指標計算
# -------------------------------

clean.radar <- function(x, y){
    d <- x[, .(N = .N, Total = sum(as.numeric(直接経費))), by = "所属機関"]
    d[, LogAmount := log10(Total)-max(log10(Total)-4)]
    d[, LogCount := log10(N)-max(log10(N)-4)]
    d[, area := y]
    as.data.table(d)
}

clean.radar_year <- function(x, y, z){
    d <- x[, .(N = .N, Total = sum(as.numeric(直接経費))), by = "所属機関"]
    d[, LogAmount := log10(Total)-max(log10(Total)-4)]
    d[, LogCount := log10(N)-max(log10(N)-4)]
    d[, area := y]
    d[, 年度 := z]
    as.data.table(d)
}



# ===============================================
# 総計
# ===============================================

# ------------
# 中区分
# ------------

observeEvent(input$submit_radar_profile, {
    
    # 機関情報の入力の有無を確認
    req(input$org_radar_profile)
    
    # DFの整理
    tmp_radar_total_M <- DF_radar_total
    tmp_radar_total_M <- tmp_radar_total_M[年度 %in% input$year_radar_profile[1]:input$year_radar_profile[2], -"大区分"]
    tmp_radar_total_M <- unique(tmp_radar_total_M)
    tmp_radar_total_M <- tmp_radar_total_M[!is.na(中区分コード)]
    tmp_radar_total_M <- tmp_radar_total_M[, .(data = list(.SD)), by = 中区分コード]
    tmp_radar_total_M[, clean := list(map2(data, 中区分コード, clean.radar))]
        
    tmp_radar_total_M <- bind_rows(tmp_radar_total_M[中区分コード != "", clean]) 
    tmp_radar_total_M <- tmp_radar_total_M[, .(所属機関, LogAmount, LogCount, area)]
    tmp_radar_total_M <- melt(tmp_radar_total_M, measure.vars = c("LogAmount", "LogCount"), variable.name = "key", value.name = "value")
    tmp_radar_total_M <- dcast(tmp_radar_total_M, formula = 所属機関 + key ~ area, fill = 0)
    tmp_radar_total_M <- melt(tmp_radar_total_M, id.vars = c("所属機関", "key"), variable.name = "area", value.name = "value")
    tmp_radar_total_M[, 指標 := ifelse(str_detect(key, "Amount"), "件数", "総額")]
        
    tmp_radar_total_M <- tmp_radar_total_M[所属機関 %in% input$org_radar_profile]
    tmp_radar_total_M <- tmp_radar_total_M[指標 == input$index_radar_profile]
    tmp_radar_total_M[, area := as.numeric(as.character(area))]
    tmp_radar_total_M[, area := factor(area, levels = c(area[1], sort(area[-1],decreasing = T)))]
        
    # ※研究機関とobserveEventを連動させるため、研究機関を外に出しておく
    org <- input$org_radar_profile
    
    # グラフ描画
    output$radar_total_m <- renderEcharts4r({
        
        req(org)
        radar_plot_m <- tmp_radar_total_M %>%
            dcast(formula = area ~ 所属機関, value.var = "value") %>%
            e_charts(area, renderer = "svg")
            
        for (i in 1:length(org)) {
                
            radar_plot_m <- radar_plot_m %>%
                e_radar_(org[i], max = 4, radar = list(splitNumber = 4))
                
            } 
            
        radar_plot_m

        })

})
    
    
# ------------
# 大区分
# ------------

# 大区分ごとにネスト
observeEvent(input$submit_radar_profile, {
    
    # 機関情報の入力の有無を確認
    req(input$org_radar_profile)
    
    # DFの整理
    tmp_radar_total_L <- DF_radar_total
    tmp_radar_total_L <- tmp_radar_total_L[年度 %in% input$year_radar_profile[1]:input$year_radar_profile[2]]
    tmp_radar_total_L <- tmp_radar_total_L[, .(data = list(.SD)), by = 大区分]
    tmp_radar_total_L[, clean := list(map2(data, 大区分, clean.radar))]
        
    tmp_radar_total_L <- bind_rows(tmp_radar_total_L[, clean]) 
    tmp_radar_total_L <- tmp_radar_total_L[, .(所属機関, LogAmount, LogCount, area)]
    tmp_radar_total_L <- melt(tmp_radar_total_L, measure.vars = c("LogAmount", "LogCount"), variable.name = "key", value.name = "value")
    tmp_radar_total_L <- dcast(tmp_radar_total_L, formula = 所属機関 + key ~ area, fill = 0)
    tmp_radar_total_L <- melt(tmp_radar_total_L, id.vars = c("所属機関", "key"), variable.name = "area", value.name = "value")
    tmp_radar_total_L[, 指標 := ifelse(str_detect(key, "Amount"), "件数", "総額")]
        
    tmp_radar_total_L <- tmp_radar_total_L[所属機関 %in% input$org_radar_profile]
    tmp_radar_total_L <- tmp_radar_total_L[指標 == input$index_radar_profile]
    tmp_radar_total_L[, area := as.character(area)]
    tmp_radar_total_L[, area := factor(area, levels = c(area[1], sort(area[-1],decreasing = T)))]
    

    # ※研究機関とobserveEventを連動させるため、研究機関を外に出しておく
    org <- input$org_radar_profile
    
    # グラフ描画
    output$radar_total_l <- renderEcharts4r({
        
        req(org)
        radar_plot_l <- tmp_radar_total_L %>%
            dcast(formula = area ~ 所属機関, value.var = "value") %>%
            e_charts(area, renderer = "svg")
        
        for (i in 1:length(org)) {
            
            radar_plot_l <- radar_plot_l %>%
                e_radar_(org[i], max = 4, radar = list(splitNumber = 4))
            
        }
        
        #　グラフ出力
        radar_plot_l
        
        })
    
    })




# ===============================================
# 年次推移
# ===============================================

# ------------
# 中区分
# ------------

observeEvent(input$submit_radar_profile, {
    
    # 機関情報の入力の有無を確認
    req(input$org_radar_profile)
    
    # DFの整理
    tmp_radar_year_M <- DF_radar_total
    tmp_radar_year_M <- tmp_radar_year_M[年度 %in% input$year_radar_profile[1]:input$year_radar_profile[2], -"大区分"]
    tmp_radar_year_M <- unique(tmp_radar_year_M)
    tmp_radar_year_M <- tmp_radar_year_M[!is.na(中区分コード)]
    tmp_radar_year_M <- tmp_radar_year_M[, .(data = list(.SD)), by = c("中区分コード", "年度")]
    tmp_radar_year_M[, clean := list(pmap(list(data, 中区分コード, 年度), clean.radar_year))]
    
    tmp_radar_year_M <- bind_rows(tmp_radar_year_M[中区分コード != "", clean]) 
    tmp_radar_year_M <- tmp_radar_year_M[, .(所属機関, LogAmount, LogCount, area, 年度)]
    tmp_radar_year_M <- melt(tmp_radar_year_M, measure.vars = c("LogAmount", "LogCount"), variable.name = "key", value.name = "value")
    tmp_radar_year_M <- dcast(tmp_radar_year_M, formula = 所属機関 + key + 年度 ~ area, fill = 0)
    tmp_radar_year_M <- melt(tmp_radar_year_M, id.vars = c("所属機関", "key", "年度"), variable.name = "area", value.name = "value")
    tmp_radar_year_M[, 指標 := ifelse(str_detect(key, "Amount"), "件数", "総額")]
    
    tmp_radar_year_M <- tmp_radar_year_M[所属機関 == input$org_radar_profile[1]]
    tmp_radar_year_M <- tmp_radar_year_M[指標 == input$index_radar_profile]
    tmp_radar_year_M[, area := as.numeric(as.character(area))]
    tmp_radar_year_M[, area := factor(area, levels = c(unique(area)[1], sort(unique(area)[-1], decreasing = T)))]
    
    # ※研究機関とobserveEventを連動させるため、研究機関を外に出しておく
    year <- as.character(input$year_radar_profile[1]:input$year_radar_profile[2])
    
    # グラフ描画
    output$radar_year_m <- renderEcharts4r({
        
        req(year)
        radar_plot_m <- tmp_radar_year_M %>%
            dcast(formula = area ~ 年度, value.var = "value") %>%
            e_charts(area, renderer = "svg")
        
        for (i in 1:length(year)) {
            
            radar_plot_m <- radar_plot_m %>%
                e_radar_(year[i], max = 4, radar = list(splitNumber = 4))
            
        } 
        
        radar_plot_m
        
    })
    
})


# ------------
# 大区分
# ------------

# 大区分ごとにネスト
observeEvent(input$submit_radar_profile, {
    
    # 機関情報の入力の有無を確認
    req(input$org_radar_profile)
    
    # DFの整理
    tmp_radar_year_L <- DF_radar_total
    tmp_radar_year_L <- tmp_radar_year_L[年度 %in% input$year_radar_profile[1]:input$year_radar_profile[2]]
    tmp_radar_year_L <- tmp_radar_year_L[, .(data = list(.SD)), by = c("大区分", "年度")]
    tmp_radar_year_L[, clean := list(pmap(list(data, 大区分, 年度), clean.radar_year))]
    
    tmp_radar_year_L <- bind_rows(tmp_radar_year_L[, clean]) 
    tmp_radar_year_L <- tmp_radar_year_L[, .(所属機関, LogAmount, LogCount, area, 年度)]
    tmp_radar_year_L <- melt(tmp_radar_year_L, measure.vars = c("LogAmount", "LogCount"), variable.name = "key", value.name = "value")
    tmp_radar_year_L <- dcast(tmp_radar_year_L, formula = 所属機関 + key + 年度 ~ area, fill = 0)
    tmp_radar_year_L <- melt(tmp_radar_year_L, id.vars = c("所属機関", "key", "年度"), variable.name = "area", value.name = "value")
    tmp_radar_year_L[, 指標 := ifelse(str_detect(key, "Amount"), "件数", "総額")]
    
    tmp_radar_year_L <- tmp_radar_year_L[所属機関 == input$org_radar_profile[1]]
    tmp_radar_year_L <- tmp_radar_year_L[指標 == input$index_radar_profile]
    tmp_radar_year_L[, area := as.character(area)]
    tmp_radar_year_L[, area := factor(area, levels = unique(c(area[1], sort(area[-1],decreasing = T))))]
    
    
    # ※研究機関とobserveEventを連動させるため、研究機関を外に出しておく
    year <- as.character(input$year_radar_profile[1]:input$year_radar_profile[2])
    
    # グラフ描画
    output$radar_year_l <- renderEcharts4r({
        
        req(year)
        radar_plot_l <- tmp_radar_year_L %>%
            dcast(formula = area ~ 年度, value.var = "value") %>%
            e_charts(area, renderer = "svg")
        
        for (i in 1:length(year)) {
            
            radar_plot_l <- radar_plot_l %>%
                e_radar_(year[i], max = 4, radar = list(splitNumber = 4))
            
        }
        
        #　グラフ出力
        radar_plot_l
        
    })
    
})




