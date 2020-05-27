df_content <- readRDS('content.rds')

thisPlot <- ggplot(df_content, aes(Country)) +
  geom_bar(fill = 'red', width = 0.75) + 
  xlab('Countries') + 
  ylab('Number of Companies') +
  coord_flip()

ggsave('Country_vs_Count.png', thisPlot, width = 16, height = 12, dpi=1000)