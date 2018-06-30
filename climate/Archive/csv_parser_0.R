library(dplyr)
library(tidyr)
library(tidyverse)
library(jsonlite)
library(rjson)
library(readr)

mapper_file <- "C:\\work\\4d-time-series-visualiser\\climate\\climate_trend_4d_visualiser\\mapper.json"

mapper_df <- mapper_file %>%  file %>% stream_in

files <- mapper_df$file

file_data <-  lapply(files, read.csv)

cols_merge <- mapper_df$merge_col

file_col_select <- lapply(mapper_df$select_col, function(x) { unlist(strsplit(x, ",")) })

merge_data <- as.data.frame(file_data[1])

merge_data <- merge_data %>% 
  select_(.dots = file_col_select[[1]])

for (i in 2:length(files) )
{
  df <- as.data.frame(file_data[i])
  
  if(!is.null (file_col_select[[i]]))
  {
    df <- df %>% 
      select_(.dots = file_col_select[[i]])
  }
  
  merge_data <- merge(merge_data, df, by.x=cols_merge[i-1], by.y=cols_merge[i])
  
}



