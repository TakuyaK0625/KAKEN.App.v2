# ---------------------
# データのインポート
# ---------------------

DF_org_total <- fread("99_InputData/DF_Master.csv", 
               select = c("所属機関", "年度", "区分名", "研究種目", "総配分額"),
               colClasses = list(character = c("所属機関", "区分名", "研究種目"), 
                                 numeric = c("年度", "総配分額"))
)


# ---------------------
# 軸ラベル
# ---------------------

axis_org_summary <- c("総額（百万円）", "件数")
names(axis_org_summary) <- c("総額", "件数")


# ------------------------
# 審査区分チェックボックス
# ------------------------

observe({
    output$area_org_summary <- renderTree({ 
        review_list
        })
})

# ------------------------
# 審査区分全選択ボタン
# ------------------------

observe({
  if (input$selectall_area_summary == 0) {
    return(NULL) 
  } else if (input$selectall_area_summary %% 2 == 0) {
    updateTree(session, "area_org_summary", data = review_list)
  } else {
    updateTree(session, "area_org_summary", data = review_list_all)
  }
})

# ------------------------
# 研究種目全選択ボタン
# ------------------------

observe({
    if (input$selectall_org_summary == 0) {
      return(NULL) 
      } else if (input$selectall_org_summary %% 2 == 0) {
      updateCheckboxGroupInput(session, "type_org_summary", NULL, choices = type_all)
      } else {
      updateCheckboxGroupInput(session, "type_org_summary", NULL, choices = type_all, selected = type_all)
      }
})

# =================================================
# 期間内の総計
# 棒グラフ　
# =================================================


# ------------------------
# サマリーデータの作成
# ------------------------

summary_org_total <- eventReactive(input$submit_org_summary, {
  
  # 一時変数
  tmp_org_total <- DF_org_total
  
  # 研究機関グループでフィルター
  if (input$group_org_summary != "全機関"){
    tmp_org_total <- tmp_org_total[所属機関 %in% c(Group[[input$group_org_summary]], input$add_org_summary)]
    }
      
  # 審査区分でフィルター
  area <- get_selected(input$area_org_summary, format = "classid") %>% unlist
  tmp_org_total <- tmp_org_total[区分名 %in% area]
      
  # 研究種目でフィルター
  tmp_org_total <- tmp_org_total[研究種目 %in% input$type_org_summary]
      
  # 集計期間でフィルター      
  tmp_org_total <- tmp_org_total[年度 %in% input$year_org_summary[1]:input$year_org_summary[2]]
      
  # 集計
  tmp_org_total <- tmp_org_total[, .(件数 = .N, "総額" = sum(as.numeric(総配分額))/1000000), by = c("所属機関", "研究種目")] 

  # 出力
  return(tmp_org_total)
  
  })
  
  
# ------------------------
# 棒グラフ
# ------------------------

output$bar_org_total <- renderEcharts4r({
  
  bar_org <- summary_org_total() %>% group_by(所属機関) %>%
    summarize(Total = sum(eval(as.name(input$bar_y_org_total)))) %>%
    arrange(-Total) %>%
    head(input$bar_n_org_total) %>%
    pull(所属機関)
  
  summary_org_total() %>%
    filter(所属機関 %in% bar_org) %>%
    .[order(factor(.$所属機関, levels = bar_org)), ] %>%
    mutate(所属機関 = str_replace(所属機関, "大学$", "")) %>%
    group_by(研究種目) %>%
    e_charts(x = 所属機関, renderer = "svg") %>%
    e_bar_(input$bar_y_org_total, stack = "研究種目") %>%
    e_x_axis(axisLabel = list(fontSize = 10)) %>%
    e_tooltip(trigger = "axis") %>%
    e_axis_labels(y = axis_org_summary[[input$bar_y_org_total]]) %>%
#    e_toolbox_feature(feature = "saveAsImage") %>%
    e_grid(left = 100, top = 80)
  
  })

# ------------------------
# 集計表
# ------------------------

output$table_org_total <- renderDataTable({
      
  summary_org_total() %>% 
  datatable(rownames = FALSE)
  
  })
  
# ------------------------
# 集計表のダウンロード
# ------------------------

output$download_org_total <- downloadHandler(
  
  filename = "kaken_summary.csv",
  content = function(file) {
    write.csv(summary_org_total() %>% select(-color), row.names = FALSE, fileEncoding = "CP932")
    }
  
  )



# =================================================
# 期間内の年次推移
# 折れ線
# =================================================


# ------------------------
# サマリーデータの作成
# ------------------------

summary_org_year <- eventReactive(input$submit_org_summary, {
  
  # 一時変数
  tmp_org_year <- DF_org_total
  
  # 研究機関グループでフィルター
  if (input$group_org_summary != "全機関"){
    tmp_org_year <- tmp_org_year[所属機関 %in% c(Group[[input$group_org_summary]], input$add_org_summary)]
  }
  
  # 審査区分でフィルター
  area <- get_selected(input$area_org_summary, format = "classid") %>% unlist
  tmp_org_year <- tmp_org_year[区分名 %in% area]
  
  # 研究種目でフィルター
  tmp_org_year <- tmp_org_year[研究種目 %in% input$type_org_summary]
  
  # 集計期間でフィルター      
  tmp_org_year <- tmp_org_year[年度 %in% input$year_org_summary[1]:input$year_org_summary[2]]
  
  # 集計
  tmp_org_year <- tmp_org_year[, .(件数 = .N, 総額 = sum(as.numeric(総配分額))/1000000), by = c("所属機関", "年度")] 
  
  # 出力
  tmp_org_year

})


# ------------------------
# 折れ線
# ------------------------

output$line_org_year <- renderEcharts4r({
  
  # 集計期間の合計が多い機関
  line_org <- summary_org_year() %>%
    group_by(所属機関) %>%
    summarize(Total = sum(eval(as.name(input$line_y_org_year)))) %>%
    arrange(-Total) %>%
    head(input$line_n_org_year) %>%
    pull(所属機関) %>%
    unique
  
  # グラフ描画
  summary_org_year() %>%
    filter(所属機関 %in% line_org) %>%
    mutate(所属機関 = str_replace(所属機関, "大学$", "")) %>%
    mutate(年度 = as.factor(年度)) %>%
    group_by(所属機関) %>%
    e_charts(x = 年度, renderer = "svg") %>%
    e_line_(input$line_y_org_year) %>%
    e_tooltip(trigger = "item") %>%
    e_axis_labels(y = axis_org_summary[[input$line_y_org_year]]) %>%
    e_grid(left = 100, top = 80)
  

})

# ------------------------
# 集計表
# ------------------------

output$table_org_year <- renderDataTable({
  
  summary_org_year() %>% 
    datatable(rownames = FALSE)
  
})

# ------------------------
# 集計表のダウンロード
# ------------------------

output$download_org_year <- downloadHandler(
  
  filename = "kaken_summary.csv",
  content = function(file) {
    write.csv(summary_org_year() %>% select(-color), row.names = FALSE, fileEncoding = "CP932")
  }
  
)