

# for文の中で使うパラミターを外出し
targetID <- "50272020"
distance <- 4
    
# データのフィルター
DF_filter <- DF_network %>%
    filter(年度 %in% 2018:2018) 

# データがない場合はストップ
req(nrow(DF_filter) != 0)


# グラフの作成
g <- DF_filter %>%
    select(V1, V2) %>%
    graph.data.frame(vertices = DF_researcher[, "ID"] %>% unique, directed = F)

# 距離別の研究者リスト
friends_list <- list()
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

DF_network_Link %>% 
    forceNetwork(Nodes = DF_network_nodes, 
                 Source = "id.x", 
                 Target = "id.y", 
                 NodeID = "ID", 
                 Group = "Distance",
                 Nodesize = "size",
                 opacity = 0.8, 
                 zoom = TRUE,
                 legend = TRUE,
                 colourScale = JS('d3.scaleOrdinal().domain(["0", "1", "2", "3", "4"]).range(["#E8505B", "#F9D56E", "#F3ECC2", "#14B1AB", "0F4C75"])')
    )

