library(dplyr)
library(tidyr)
library(tidyverse)
library(jsonlite)
library(rjson)
library(ndjson)
library(readr)

setwd("C:\\work\\4d-time-series-visualiser\\climate\\climate_trend_4d_visualiser")

rain_data <- read.csv("rainfall_data_1901_2016.csv")
min_temp_data <- read.csv("min_temperature_1901_2016.csv")
max_temp_data <- read.csv("max_temperature_1901_2016.csv")


rain_max_month_idx <- max.col(rain_data[2:13], "first")

MAX_RAIN_MONTH <- colnames(rain_data)[rain_max_month_idx]

rain_data <- cbind(rain_data,MAX_RAIN_MONTH)

monsoon_rain <- rain_data$JJAS

LPA_monsoon <- 8900

lower_limit_monsoon <- .96 * LPA_monsoon
upper_limit_monsoon <- 1.04 * LPA_monsoon

rain_data$MONSOON_RAIN_LEVEL <- "Normal"

rain_data$MONSOON_RAIN_LEVEL[rain_data$JJAS > upper_limit_monsoon] <- "Above Normal"
rain_data$MONSOON_RAIN_LEVEL[rain_data$JJAS <lower_limit_monsoon] <- "Below Normal"

min_temp_data$AVG_MIN_TEMP <- round(rowMeans(min_temp_data[,2:13], na.rm =  TRUE),2)
max_temp_data$AVG_MAX_TEMP <- round(rowMeans(max_temp_data[,2:13], na.rm =  TRUE),2)  

  
temp_data_merge <- merge(min_temp_data, max_temp_data, by = "YEAR")
temp_data_merge %>% select(YEAR, AVG_MIN_TEMP, AVG_MAX_TEMP)

climate_df <- merge(rain_data, temp_data_merge, by="YEAR")
climate_df <- select(climate_df, YEAR, ANN, MONSOON_RAIN_LEVEL, AVG_MAX_TEMP, AVG_MIN_TEMP)

colnames(climate_df)[colnames(climate_df) == 'ANN'] <- 'ANNUAL_RAINFALL'

climate_json <- jsonlite::toJSON(climate_df)

write_lines(climate_json, "C:/work/4d-time-series-visualiser/climate/climate_data.json")

