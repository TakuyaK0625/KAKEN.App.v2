# ------------------------
# データインポート
# ------------------------

DF_project_detail <- fread("99_InputData/DF_Master.csv", 
                 select = c("所属機関", "年度", "区分名", "研究種目", "職名", "直接経費", "年数", "分担者数", "キーワード"),
                 colClasses = list(character = c("所属機関", "区分名", "研究種目", "職名", "キーワード"), 
                                   numeric = c("年度", "直接経費", "年数", "分担者数"))
)


# ------------------------
# 審査区分チェックボックス
# ------------------------

observe({
    output$area_project_detail <- renderTree({ review_list })
})


# ------------------------
# 審査区分全選択ボタン
# ------------------------

observe({
    if (input$selectall_area_project_detail == 0) {
        return(NULL) 
    } else if (input$selectall_area_project_detail %% 2 == 0) {
        updateTree(session, "area_project_detail", data = review_list)
    } else {
        updateTree(session, "area_project_detail", data = review_list_all)
    }
})


# ------------------------
# 研究種目全選択ボタン
# ------------------------

observe({
    if (input$selectall_project_detail == 0) {
        return (NULL)
    } else if (input$selectall_project_detail %% 2 == 0) {
        updateCheckboxGroupInput(session, "type_project_detail", NULL, choices = type_all)
    } else {
        updateCheckboxGroupInput(session, "type_project_detail", NULL, choices = type_all, selected = type_all)
    }
})


# データのフィルター
summary_project_detail <- eventReactive(input$submit_project_detail, {
    
    # 一時変数
    tmp_project_detail <- DF_project_detail
    # 研究機関グループでフィルター
    if (input$group_project_detail != "全機関"){
        tmp_project_detail <- tmp_project_detail[所属機関 %in% Group[[input$group_project_detail]]]
        }
    # 審査区分でフィルター
    area <- get_selected(input$area_project_detail, format = "classid") %>% unlist
    tmp_project_detail <- tmp_project_detail[区分名 %in% area] 
    # 研究種目でフィルター
    tmp_project_detail <- tmp_project_detail[研究種目 %in% input$type_project_detail]
    # 年度でフィルター
    tmp_project_detail <- tmp_project_detail[年度 %in% input$year_project_detail[1]:input$year_project_detail[2]]
    # 出力
    return(tmp_project_detail)
    
    })
    

# -----------------------------------
# 職名
# -----------------------------------

# DFの整理
jobtitle_summary <- reactive({
    
    summary_project_detail() %>%
        .[, .(件数 = .N), by = .(区分名, 職名)] %>%
        .[, 職名 := factor(職名, levels = c("教授", "准教授", "講師", "助教", "その他"))] %>%
        .[, 割合 := 100 * 件数/sum(件数), by = 区分名] %>%
        .[, 区分名 := str_replace_all(区分名, "および|、", "\n")]
})

# 棒グラフ（件数）
output$jobtitle_count <- renderEcharts4r({
    
    jobtitle_summary() %>%
        group_by(職名) %>% 
        e_charts(区分名, renderer = "svg") %>%
        e_bar(件数, stack = "grp") %>%
        e_x_axis(axisLabel = list(fontSize = 12)) %>%
        e_flip_coords() %>%
        e_tooltip(trigger = "axis")
    
    })

# 棒グラフ（割合）
output$jobtitle_ratio <- renderEcharts4r({
    
    jobtitle_summary() %>% 
        group_by(職名) %>% 
        e_charts(区分名, renderer = "svg") %>%
        e_bar(割合, stack = "grp") %>%
        e_x_axis(axisLabel = list(fontSize = 12)) %>%
        e_y_axis(max = 100) %>%
        e_flip_coords() %>%
        e_tooltip(trigger = "axis")
    
    })

# DTの出力
output$jobtitle_DT <- renderDataTable({
    
    jobtitle_summary() %>%
        datatable(rownames = F)
    
})

    
# -----------------------------------
# 年数
# -----------------------------------    

# グラフの描画
output$years <- renderEcharts4r({
    
    summary_project_detail() %>% 
        mutate(区分名 = str_replace_all(区分名, "および|、", "\n")) %>%
        group_by(区分名) %>%
        e_charts(renderer = "svg") %>%
        e_boxplot(年数) %>%
        e_x_axis(axisLabel = list(fontSize = 10)) %>%
        e_tooltip(trigger = "axis")
    
})

# DTの出力
output$year_DT <- renderDataTable({
    
    summary_project_detail() %>% 
        mutate(区分名 = str_replace_all(区分名, "および|、", "\n")) %>%
        group_by(区分名) %>%
        summarize(Min = min(年数), 
                  "1Q" = quantile(年数, 0.25), 
                  Median = median(年数), 
                  Mean = round(mean(年数), 2), 
                  "3Q" = quantile(年数, 0.75),
                  Max = max(年数)) %>%
        datatable(rownames = F)
    
})
        
# -----------------------------------
# 直接経費総額
# -----------------------------------    

# グラフの描画
output$directcost <- renderEcharts4r({
    
    summary_project_detail() %>%
        mutate(区分名 = str_replace_all(区分名, "および|、", "\n")) %>%
        mutate(`直接経費（千円）` = 直接経費/1000) %>%
        group_by(区分名) %>%
        e_charts(renderer = "svg") %>%
        e_boxplot(`直接経費（千円）`) %>%
        e_x_axis(axisLabel = list(fontSize = 10)) %>%
        e_tooltip(trigger = "axis")

    })
    
    
# DTの出力
output$directcost_DT <- renderDataTable({
    
    summary_project_detail() %>%
        mutate(区分名 = str_replace_all(区分名, "および|、", "\n")) %>%
        group_by(区分名) %>%
        mutate(`直接経費（千円）` = 直接経費 / 1000) %>%
        summarize(Min = min(`直接経費（千円）`), 
                  "1Q" = quantile(`直接経費（千円）`, 0.25), 
                  Median = median(`直接経費（千円）`), 
                  Mean = round(mean(`直接経費（千円）`), 2), 
                  "3Q" = quantile(`直接経費（千円）`, 0.75),
                  Max = max(`直接経費（千円）`)) %>%
        datatable(rownames = F)
    

})


# -----------------------------------
# 研究分担者数
# -----------------------------------

# グラフ描画
output$buntan <- renderEcharts4r({
    
    summary_project_detail() %>%
        mutate(区分名 = str_replace_all(区分名, "および|、", "\n")) %>%
        group_by(区分名) %>%
        e_charts(renderer = "svg") %>%
        e_boxplot(分担者数) %>%
        e_x_axis(axisLabel = list(fontSize = 10)) %>%
        e_tooltip(trigger = "axis")

    })

# DTの出力
output$buntan_DT <- renderDataTable({
    
    summary_project_detail() %>%
        mutate(区分名 = str_replace_all(区分名, "および|、", "\n")) %>%
        group_by(区分名) %>%
        summarize(Min = min(分担者数), 
                  "1Q" = quantile(分担者数, 0.25), 
                  Median = median(分担者数), 
                  Mean = round(mean(分担者数), 2), 
                  "3Q" = quantile(分担者数, 0.75),
                  Max = max(分担者数)) %>%
        datatable(rownames = F)
    
})

# -----------------------------------
# キーワード
# -----------------------------------    

# データの整形
keyword_df <- reactive({
    
    summary_project_detail()$キーワード %>% 
        str_split(" / ") %>% 
        unlist() %>% 
        table(dnn = list("語彙")) %>% 
        as.data.frame(responseName = "頻度") %>%
        filter(語彙 != "") %>%
        arrange(-頻度)
    
    })
    
# WordCloud
output$keyword_cloud <- renderWordcloud2({
    
    keyword_df() %>% filter(頻度 > 1) %>%
        wordcloud2(size = 0.5)
    
    })
    
# キーワード：頻度表
output$keyword_table <- renderDataTable({
    
    keyword_df() %>% datatable(rownames = F) 
    
    })

