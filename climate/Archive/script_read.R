library(dplyr)
library(tidyr)
library(elastic)
library(elasticsearchr)
library(RJSONIO)
library(RCurl)
library(httr)
library(jsonlite)
######Summary########
# The input is a text file that contains rainfall data for the years 1871 to 2016.
# The data is for the months from Jan-Dec, 4 seasons and annual rainfall
# readLines reads some or all lines from a text. It returns a character
# strSplit splits the data by space and returns a single list containing a vector
# The vector is converted to a matrix. This excludes The first 18 elements.. 
# ..as they are the headers
# Columns names are added using colnames
# Matrix is converted into a data frame


setwd("C:/work/4d-time-series-visualiser/Met")

rainfall_data <- readLines("rainfall.txt")

rainfall_data_l <- strsplit(rainfall_data, " ")

rainfall_data_v <- rainfall_data_l[[1]]

remove = c(1:18)

rainfall_data_m <- matrix(rainfall_data_v[-remove], ncol = 18, byrow = TRUE)

colnames(rainfall_data_m) <- rainfall_data_v[1:18]

rainfall_data_df <- as.data.frame(rainfall_data_m)


temp_data <- read.csv("temperature_1901_2015.csv")

#temp_data_c <- subset(temp_data, select = -c(temp_data$Month, temp_data$Country, temp_data$ISO2, temp_data$ISO3))

temp_data_c <- within(temp_data,rm("Month", "Country", "ISO2", "ISO3"))

temp_data_df <- temp_data_c %>% group_by(X.Year) %>% summarise(avg_tas = round(mean(tas),2))

climate_df <- merge(rainfall_data_df, temp_data_df, by.x = "YEAR", by.y = "X.Year")

#col_indx <- sapply(climate_df, is.factor)
#climate_df[col_indx] <- lapply(climate_df[col_indx], function(x) as.numeric(as.character(x)))

climate_json <- jsonlite::toJSON(climate_df)

x <- cat(climate_json)

x 

jsonlite::write_json(cat(climate_json), "climate_data.json" )

write.csv(as.matrix(climate_df),"climate_data.csv",row.names = F)


####elastic search ####

connect()             

map_climate <- '{
      "properties": { 
"YEAR":    { "type": "integer"  }, 
"JAN":     { "type": "integer" },
"FEB":     { "type": "integer"  },
"MAR":     { "type": "integer"  },
"APR":     { "type": "integer"  },
"MAY":     { "type": "integer"  },
"JUN":     { "type": "integer"  },
"JUL":     { "type": "integer"  },
"AUG":     { "type": "integer"  },
"SEP":     { "type": "integer"  },
"OCT":     { "type": "integer"  },
"NOV":     { "type": "integer"  },
"DEC":     { "type": "integer"  },
"JF":     { "type": "integer" }, 
"MAM":     { "type": "integer"  },
"JJAS":     { "type": "integer"  },
"OND":     { "type": "integer"  },
"ANN":     { "type": "integer"  },
"avg_tas":     { "type": "float" }
} }' 


index_delete("idx_climate")

index_create("idx_climate")

mapping_create("idx_climate", "idx_climate", update_all_types=TRUE, body = map_climate)

climate_file <- "C:/work/4d-time-series-visualiser/Met/climate_data.csv"

climate_df <- read.csv(file)

climate_es<- docs_bulk(climate_df, index="idx_climate", type = "idx_climate", raw=TRUE)



for_everything <-'{ "query": {
                          "match_all": {}
}}'

climate_all <- fromJSON(Search(index="idx_climate", body = for_everything, raw = TRUE))

climate_all_json <- toJSON(climate_all, pretty = TRUE) 

cat(climate_all_json)


for_something <- '{ "query": {
  "match_phrase": {"YEAR" : "2015"}
}}'


climate_1991 <- fromJSON(Search(index="idx_climate", body = for_something, raw = TRUE))

climate_1991_json <- toJSON(climate_1991, pretty = TRUE) 

cat(climate_1991_json)


source_filter <- '{
"_source": ["jf","mam","jjas","ond","ann"]
}'

season_data <-  fromJSON(Search(index="idx_climate", body = source_filter, raw = TRUE))

season_data_json <- toJSON(season_data, pretty = TRUE)

cat(season_data_json)

year_aggs <- '{
"aggs" : {
    "all_yr" : {
      "terms" : { "field" : "YEAR"},
       "aggs" : {
            "year_details" : {
            "sort": [
            { 
              "sort_year": {
                  "order": "desc"
                }
            }]
            } } } } }'

year_aggs<- '{
		"aggs": {
"year_data": {
"terms": {
"field": "YEAR"
}}}}'


climate_agg_year <- fromJSON(Search(index="idx_climate", body = year_aggs, raw = TRUE))

climate_year_agg_json <- toJSON(climate_agg_year, pretty = TRUE) 

cat(climate_year_agg_json)



