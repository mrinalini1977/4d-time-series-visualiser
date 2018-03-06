library(jsonlite)
library(rjson)
library(RCurl)
library(RJSONIO)
library(dplyr)
library(tidyr)
library(tidyjson)

buildData <- paste(readLines("data/buildResults.json"), collapse = " ")

init <- buildData %>% 
  enter_object("aggregations") %>%
  enter_object("data")%>%
  enter_object("buckets") %>%
  gather_array(column.name = "agg_bucket_index")%>% 
  enter_object("output")  %>%
  enter_object("buckets") %>%
  gather_array("output_bucket_index") %>%
  enter_object("runs") %>%
  enter_object("buckets") %>%
  gather_array(column.name = "runs_bucket_index") %>% 
  enter_object("latest") %>%
  enter_object("hits")  %>%
  enter_object("hits")  %>%
  gather_array(column.name = "hits_bucket_index") %>%
  enter_object("_source")

sourceobj <- init %>% 
  spread_values(
    buildName = jstring("BuildName"),
    time = jstring("timestamp"),
    commits = jstring("Commits" ) ) %>%
    tbl_df()

artefactobj <- init %>% 
    enter_object("artefacts") %>%
  gather_array(column.name = "artefacts_index") %>%
  spread_values( artefact_size = jnumber("size"),  
                 artefact_name = jstring("name")) %>%
  json_lengths() %>%
  tbl_df()

artefactGroupobj<- artefactobj %>% group_by(agg_bucket_index, output_bucket_index, runs_bucket_index, hits_bucket_index) %>%
  summarise(artefact_size_total = sum(artefact_size), artefact_count = n()) %>%
  tbl_df()

joinartefact <- inner_join(sourceobj, artefactGroupobj) %>%
  select(-document.id,-agg_bucket_index, -output_bucket_index, -runs_bucket_index, -hits_bucket_index)


class(joinartefact)


df_build_data <- as.data.frame(joinartefact)

df_build_data$buildDate <- as.Date(df_build_data$time)
df_build_data$buildTime <- format(as.POSIXct(df_build_data$time, format = "%Y-%m-%dT%H:%M:%S", tz="GMT") ,format = "%H:%M:%S") 

df_build_data = rename(df_build_data, dateTime = time)

write.csv(as.matrix(within(df_build_data, rm("time"))),"data/buildExtract.csv")


