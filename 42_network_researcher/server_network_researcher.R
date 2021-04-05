# --------------------------------------------------
# データインポート
# --------------------------------------------------

DF_network <- fread("99_InputData/DF_Network.csv", 
                  colClasses = rep("character", 6))

DF_researcher <- fread("99_InputData/researcher_net.csv", 
                       colClasses = list(character = c(1:3, 5:6), 
                                         integer = 4))


# --------------------------------------------------
# 審査区分チェックボックス
# --------------------------------------------------

observe({
    output$area_net_researcher <- renderTree({ review_list })
    })


# ------------------------
# 審査区分全選択ボタン
# ------------------------

observe({
  if (input$selectall_area_net_researcher == 0) {
    return(NULL) 
  } else if (input$selectall_area_net_researcher %% 2 == 0) {
    updateTree(session, "area_net_researcher", data = review_list)
  } else {
    updateTree(session, "area_net_researcher", data = review_list_all)
  }
})



# --------------------------------------------------
# 研究種目全選択ボタン
# --------------------------------------------------

observe({
    if(input$selectall_net_researcher == 0) {
      return(NULL)
    } else if (input$selectall_net_researcher %% 2 == 0) {
      updateCheckboxGroupInput(session, "type_net_researcher", NULL, choices = type_net)
    } else {
      updateCheckboxGroupInput(session, "type_net_researcher", NULL, choices = type_net, selected = type_net)
    }
})


# 計算開始
observeEvent(input$submit_net_researcher, {
  
  # for文の中で使うパラミターを外出し
  targetID <- input$id_net_researcher
  distance <- input$distance_net_researcher
  
  # 注目する研究者の入力チェック
  if(targetID == ""){
    showModal(modalDialog(title = "エラー", "注目する研究者の研究者番号を入力してください。", easyClose = TRUE, footer = modalButton("OK")))
  }
  req(targetID != "")
  
  # 研究者番号が存在するかチェック
  if(!(targetID %in% DF_researcher$ID)){
    showModal(modalDialog(title = "エラー", "入力された研究者番号では、2018年度から2020年度の科研費における共同研究の実績がありません。", easyClose = TRUE, footer = modalButton("OK")))
  }
  req(targetID %in% DF_researcher$ID)
  
  
  
  # データのフィルター
  DF_filter <- DF_network %>%
    filter(年度 %in% input$year_net_researcher[1]:input$year_net_researcher[2]) %>%
    filter(研究種目 %in% input$type_net_researcher) %>%
    filter(区分名 %in% get_selected(input$area_net_researcher, format = "classid") %>% unlist)
  
  # 審査区分、研究種目の入力チェック
  if(nrow(DF_filter) == 0){
    showModal(modalDialog(title = "エラー", "審査区分や研究種目を選択してください", easyClose = TRUE, footer = modalButton("OK")))
  }
  req(nrow(DF_filter) != 0)
  
  # グラフの作成
  g <- DF_filter %>%
    select(V1, V2) %>%
    graph.data.frame(vertices = DF_researcher[, "ID"] %>% unique, directed = F)
  
  # 距離別の研究者リスト
  friends_list <- list()
  friends_list[[1]] <- targetID
  for (i in 0:distance) {
    sub_g <- make_ego_graph(g, order = i, nodes = V(g)[[targetID]], mode = "all")
    friends_list[[(i + 1)]] <- V(sub_g[[1]]) %>% attributes() %>% .$names
    }
  
  # 距離別の研究者DF（差分）
  researcher_distance_df <- data.frame("ID" = targetID, "Distance" = 0)
  for (i in 1:distance) {
    diff <- setdiff(friends_list[[i + 1]], friends_list[[i]])
    
    if (length(diff) == 0) {
      df <- data.frame("ID" = NA, "Distance" = i)
    } else {
      df <- data.frame("ID" = diff, "Distance" = i)
    }
    researcher_distance_df <- bind_rows(researcher_distance_df, df)
  }
  
  # 研究課題番号
  projectID <- DF_filter %>% 
    pivot_longer(cols = c(V1, V2), names_to = "V", values_to = "ID") %>%
    filter(ID %in% (researcher_distance_df %>% filter(Distance <= distance -1) %>% pull(ID))) %>%
    pull(研究課題番号) %>%
    unique
  
  # 研究課題番号がない場合はストップ
  if(length(projectID) == 0){
    showModal(modalDialog(title = "エラー", "該当する研究課題がありません", easyClose = TRUE, footer = modalButton("OK")))
  }
  req(length(projectID) != 0)
  
  
  
  # 研究者Nodesリスト
  DF_network_nodes <- DF_filter %>%
    filter(研究課題番号 %in% projectID) %>%
    select(研究課題番号, V1, V2) %>%
    pivot_longer(cols = c(V1, V2), names_to = "V", values_to = "ID") %>%
    select(研究課題番号, ID) %>%
    unique %>%
    count(ID) %>%
    left_join(researcher_distance_df, by = "ID") %>%
    mutate(Distance = ifelse(is.na(Distance), distance, Distance)) %>%
    mutate(size = 300/(Distance+1)^5) %>%
    arrange(-Distance) %>%
    mutate(Distance = as.character(Distance)) %>%
    mutate(id = 1:nrow(.) - 1) %>%
    mutate(id = as.character(id))

  # 研究者LINKリスト
  DF_network_Link <- DF_filter %>% 
    filter(研究課題番号 %in% projectID) %>%
    left_join(DF_network_nodes %>% select(ID, id), by = c("V1" = "ID")) %>%
    left_join(DF_network_nodes %>% select(ID, id), by = c("V2" = "ID"))
  
  # グラフの描画  
  output$net_researcher <- renderForceNetwork({
    
    req(nrow(DF_network_Link) != 0)
    
    DF_network_Link %>% 
      forceNetwork(Nodes = DF_network_nodes, 
                   Source = "id.x", 
                   Target = "id.y", 
                   NodeID = "ID", 
                   Group = "Distance",
                   Nodesize = "size",
                   opacity = 0.8,
                   fontSize = 12,
                   zoom = TRUE,
                   legend = TRUE,
                   colourScale = JS('d3.scaleOrdinal().domain(["0", "1", "2", "3", "4"]).range(["#E8505B", "#FFA64C", "#14B1AB", "0F4C75", "#5C1D6B"])')
#                   colourScale = JS('d3.scaleOrdinal().domain(["0", "1", "2", "3", "4"]).range(["#E8505B", "#F9D56E", "#F3ECC2", "#14B1AB", "0F4C75"])')
                   )
      
  })
  
})
  
  
  
 