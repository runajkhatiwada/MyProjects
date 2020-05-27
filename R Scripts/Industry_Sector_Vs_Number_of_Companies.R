df_content <- readRDS('all_file.rds')

colnames(df_content) = gsub(" ", "_",colnames(df_content))

summary(df_content)


thisPlot <- ggplot(df_content, aes(Sector)) +
    geom_bar(fill = 'red', width = 0.75) + 
    xlab('Industry Sector') + 
    ylab('Number of Companies') +
    coord_flip()

ggsave('this_plot.png', thisPlot, width = 16, height = 9, dpi=1600)