
about_update <- fread("99_InputData/update.csv")

output$update_DT <- renderDataTable({
    
    about_update %>%
        arrange(desc(Date)) %>%
        datatable(
            filter = "none",
            options = list(searching = FALSE, 
                           pageLength = 5, 
                           lengthChange = FALSE,
                           ordering = FALSE),
            rownames = F, 
            colnames = c("更新日","内容")
            ) %>%
        formatStyle(columns = colnames(.), fontSize = "50%")
    
})
