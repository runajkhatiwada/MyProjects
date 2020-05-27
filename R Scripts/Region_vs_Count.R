library(ggplot2)
setwd('G:\\Data Visualization\\Final Assignment\\Content\\Individuals')
df_content <- readRDS('content.rds')
thisPlot <- ggplot(df_content, aes(Region)) +
  geom_bar(fill = 'red', width = 0.75) + 
  xlab('Region') + 
  ylab('Number of Companies') +
  coord_flip()

ggsave('Region_vs_Count.png', thisPlot, width = 16, height = 12, dpi=1000)