df_content <- readRDS('all_file.rds')

colnames(df_content) = gsub(" ", "_",colnames(df_content))

summary(df_content)

thisPlot <- ggplot(df_content, aes(Publication_Year, fill = Size)) +
  geom_bar() + 
  xlab('Publication Year') + 
  ylab('Number of Companies')
ggsave('Publication_Year_Vs_Number_of_Companies.png', thisPlot, width = 16, height = 9, dpi=1600)
