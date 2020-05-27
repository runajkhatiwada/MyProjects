library(ggplot2)
library(tidyverse)

setwd('G:\\Data Visualization\\Final Assignment\\Content\\Individuals')

content <- dir('G:\\Data Visualization\\Final Assignment\\Content\\Individuals') %>% map_df(read_csv, skip = 1)
colnames(content) = gsub(" ", "_",colnames(content))
saveRDS(content, file= 'content.rds')
