library(dplyr)
library(tidyr)
library(tidyverse)
library(jsonlite)
library(rjson)
library(readr)
library(reshape2)

mapper_file <- "C:\\work\\4d-time-series-visualiser\\climate\\climate_trend_4d_visualiser\\csv_parser.json"

map_df <- mapper_file %>%  file %>% stream_in

select_col_rename <- lapply(map_df$select_col_rename, function(x) {unlist(strsplit(x,",")) })

select_col <- lapply(select_col_rename, function(x) {sapply(strsplit(x,"\\:"), `[`, 1) })

rename_col <- lapply(select_col_rename, function(x) {sapply(strsplit(x,"\\:"), `[`, 2) })

files <- map_df$file

file_data <-  lapply(files, read.csv)

reshape_col <- sapply(map_df$reshape_col, function(x) {unlist(strsplit(x,",")) })

measure_col <- map_df$measure

measure_type_col <- map_df$measure_type

k <- 1

for (i in 1:length(files) )
{
  df <- as.data.frame(file_data[i])
  
  if(!is.null (select_col[[i]]))
  {
    df <- df %>% 
      select_(.dots = select_col[[i]]) %>%
      rename_(.dots = setNames(select_col[[i]],rename_col[[i]])) %>%
      melt(    variable.name = measure_type_col[i],
               value.name = measure_col[i],
               id.vars =  reshape_col[i])
  }
  if (i > 1)
  {
    merge_df <- merge(merge_df, df)
  }
  else
  {
    merge_df<- df
  }
}

climate_json <- jsonlite::toJSON(climate_df)

write_lines(jsonlite::toJSON(merge_df), "C:\\work\\4d-time-series-visualiser\\climate\\climate_trend_4d_visualiser\\csv_output.json")



