df_content <- readRDS('all_file.rds')

colnames(df_content) = gsub(" ", "_",colnames(df_content))

summary(df_content)


thisPlot <- ggplot(df_content, aes(Size)) +
  geom_bar(fill = 'red', width = 0.75) + 
  xlab('Industry Size') + 
  ylab('Number of Companies')

ggsave('Size_vs_Count.png', thisPlot, width = 16, height = 9, dpi=1600)