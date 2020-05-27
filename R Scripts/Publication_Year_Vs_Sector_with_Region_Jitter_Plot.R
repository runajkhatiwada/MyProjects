library(ggplot2)
setwd('G:\\Data Visualization\\Final Assignment\\Content\\Individuals')
df_content <- readRDS('content.rds')
summary(df_content)
thisPlot <- ggplot(df_content, aes(Sector, Publication_Year, color = Region)) +
  geom_jitter() +
  xlab('Sector') +
  ylab('Publication Year') +
  coord_flip()
#theme(legend.position = "none")
ggsave('Publication_Year_Vs_Sector_with_Region_Jitter_Plot.png', thisPlot, width = 16, height = 12, dpi=1000)