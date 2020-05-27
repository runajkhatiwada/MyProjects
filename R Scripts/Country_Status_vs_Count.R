library(ggplot2)
setwd('G:\\Data Visualization\\Final Assignment\\Content\\Individuals')
df_content <- readRDS('content.rds')
thisPlot <- ggplot(df_content, aes(Country_Status)) +
  geom_bar(fill = 'red', width = 0.75) + 
  xlab('Country Status') + 
  ylab('Number of Companies') +
  coord_flip()

ggsave('Country_Status_vs_Count.png', thisPlot, width = 16, height = 12, dpi=1000)