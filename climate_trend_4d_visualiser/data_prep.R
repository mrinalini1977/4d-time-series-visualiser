library(dplyr)
library(tidyr)
library(jsonlite)
library(readr)


output_file <- "C:\\work\\4d-time-series-visualiser\\climate\\climate_trend_4d_visualiser\\csv_output.json"

output_df <- output_file %>%  file %>% stream_in


baseMinTemp <- with(output_df, mean(MIN_TEMP_DATA[ YEAR>=1901 & YEAR <= 1930]) )

output_df$MIN_TEMP_ANAM <- round(baseMinTemp,2) - output_df$MIN_TEMP_DATA


baseMaxTemp <- with(output_df, mean(MAX_TEMP_DATA[ YEAR>=1901 & YEAR <= 1930]) )

output_df$MAX_TEMP_ANAM <- round(baseMaxTemp,2) - output_df$MAX_TEMP_DATA


output_df$season[output_df$MONTH == 'JAN' | output_df$MONTH == 'FEB'] <- "JF"
output_df$season[output_df$MONTH == 'MAR' | output_df$MONTH == 'APR' | output_df$MONTH == 'MAY'] <- "MAM"
output_df$season[output_df$MONTH == 'JUN' | output_df$MONTH == 'JUL' | output_df$MONTH == 'AUG' | output_df$MONTH == 'SEP'] <- "JJAS"
output_df$season[output_df$MONTH == 'OCT' | output_df$MONTH == 'NOV' | output_df$MONTH == 'DEC'] <- "OND"


#output_df$MONTH_NUM <- match(output_df$MONTH, toupper(month.abb))


season_df <- output_df %>% group_by(YEAR,season) %>% summarize(RAINFALL_DATA = mean(RAINFALL_DATA), MAX_TEMP_DATA = mean(MAX_TEMP_DATA), MIN_TEMP_DATA = mean(MIN_TEMP_DATA), SEVERE_WEATHER_DATA = mean(SEVERE_WEATHER_DATA), MIN_TEMP_ANAM = mean(MIN_TEMP_ANAM), MAX_TEMP_ANAM = mean(MAX_TEMP_ANAM))

colnames(season_df)[which(colnames(season_df) == 'season')] <- 'MONTH'

output_df <- subset(output_df, select = -c(season))

season_df <- as.data.frame(season_df)

output_df <- rbind(output_df, season_df)

seasons <- c("JF","MAM","JJAS","OND")

output_df$INTERVAL <- "MONTH"

output_df$INTERVAL[output_df$MONTH %in% seasons] <- "SEASON"

output_df <- output_df[order(output_df$YEAR),] 


write_lines(jsonlite::toJSON(output_df), "C:\\work\\4d-time-series-visualiser\\climate\\climate_trend_4d_visualiser\\climate_data.json")
