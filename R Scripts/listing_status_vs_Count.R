df_content <- readRDS('all_file.rds')

colnames(df_content) = gsub(" ", "_",colnames(df_content))

summary(df_content)


thisPlot <- ggplot(df_content, aes(Country_Status)) +
  geom_bar(fill = 'red', width = 0.75) + 
  xlab('Country Status') + 
  ylab('Number of Companies')
  
ggsave('listing_status_vs_Count.png', thisPlot, width = 16, height = 9, dpi=1600)