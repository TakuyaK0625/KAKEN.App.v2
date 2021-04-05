# --------------------------------------------------
# データインポート
# --------------------------------------------------

DF_network <- fread("99_InputData/DF_Network.csv", 
                  colClasses = rep("character", 6))

DF_researcher <- fread("99_InputData/researcher_net.csv", 
                       colClasses = list(character = c(1:3, 5:6), 
                                         integer = 4))

plan(multicore)

# --------------------------------------------------
# 審査区分チェックボックス
# --------------------------------------------------

observe({
    output$area_net_all <- renderTree({ review_list })
    })


# --------------------------------------------------
# Submit button
# --------------------------------------------------

observeEvent(input$submit_network_all, {
  
  DF_network_all <- DF_network
  
  # 審査区分でフィルター
  area <- get_selected(input$area_net_all, format = "classid") %>% unlist
  DF_network_all <- DF_network_all[区分名 %in% area]
  
  # 研究種目でフィルター
  DF_network_all <- DF_network_all[研究種目 %in% input$type_net_all]
  
  # 集計期間でフィルター      
  DF_network_all <- DF_network_all[年度 %in% input$year_net_all[1]:input$year_net_all[2]]
  
  # ハイライトする研究機関
  inst <- DF_researcher[所属 %in% input$org_net_all
                          ][年度 %in% input$year_net_all[1]:input$year_net_all[2]
                              ][,ID]
  
  # グラフオブジェクト
  g <- DF_network_all %>% 
    select(V1, V2) %>%
    graph_from_data_frame(directed = FALSE)
  
  # グラフの描画
  output$network_all <- renderScatterplotThree({
    
    req(nrow(DF_network_all) != 0)
    ID <- V(g)$name
    colors <- ifelse(V(g)$name %in% inst, "blue", "orange")
    set.seed(0)
    graphjs(g, vertex.size = 0.2, vertex.label = ID)
    
  })
  
  # 中心性指標
  output$centrality <- renderDataTable({
    
    DF_researcher %>% 
      filter(研究課題番号 %in% DF_network_all$研究課題番号) %>%
      group_by(ID) %>%
      summarize(所属 = paste0(unique(所属), collapse = "/"), 代表 = sum(役割 == "代表"), 分担 = sum(役割 == "分担")) %>%
      left_join(data.frame(研究者番号 = V(g)$name, 
                    次数中心性 = degree(g), 
                    媒介中心性 = round(betweenness(g), 2), 
                    固有ベクトル中心性 = round(eigen_centrality(g)$vector, 2)),
                by = c("ID" = "研究者番号")) %>% 
      datatable(rownames = F)
  })
  
})
  
   

  
  

