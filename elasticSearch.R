library(RJSONIO)
library(elastic)
library(RCurl)
library(httr)
library(elasticsearchr)

setwd("C:")

getwd()

connect()

index_create('testes')


files <- c(system.file("examples", "test1.csv", package = "elastic"),
           system.file("examples", "test2.csv", package = "elastic"),
           system.file("examples", "test3.csv", package = "elastic"))


for (i in seq_along(files)) {
  d <- read.csv(files[[i]])
  print(d)
  b <- docs_bulk(d, index = "testes", type = "docs")
  Sys.sleep(1)
}


count("testes", "docs")

count()

index_delete("testes")
file <- system.file("examples", "test3.csv", package = "elastic")


file <- "C:/work/4d-time-series-visualiser/UNdata_religion.csv"

data_world<- read.csv(file)

class(data_world)


index_create("idx_religion")

docs_bulk(data_world, index = "idx_religion", type = "rlgs", raw = true)

?docs_bulk

index_delete("idx_religion")

idx <- elastic("http://localhost:9200", "data_world", "religion") %index% data_world


for_everything <- query ('{
                          "match_all": {}
                         }')

for_everything <-'{ "query": {
                          "match_all": {}
                         }}'



d <- elastic("http://localhost:9200", "data_world", "religion") %search% for_everything 


d <- fromJSON(Search(index="idx_religion", q = "Muslim", raw = TRUE))

d <- fromJSON(Search(index="idx_religion", body = for_everything, raw = TRUE))

Search(index="idx_religion", body = for_everything)

d <- fromJSON(Search(index="idx_religion", body = aggs_yr, raw = TRUE))


?Search

d1 <- toJSON(d, pretty = TRUE) 

aggs_yr <- '{
  "aggs" : {
    "Years" : {
      "terms" : { "field" : "Year" }
    },
"order" : { "_key" : "asc" }
  }
}'

aggs_yr <-     "aggs": {
  "latbuckets" : {
    "histogram" : {
      "field" : "decimalLatitude",
      "interval" : 5,
      "min_doc_count" : 0,
      "extended_bounds" : {
        "min" : -90,
        "max" : 90
      },
      "order" : {
        "_count" : "desc"
      }
    }
  }
}
}'


cat(d1)

?toJSON

?fromJSON

elastic()

muslim_rlgn <- query( '{
    "match" : {
      "Religion" : "Muslim"
    }
  }')

Search(index="data_world",  q='Religion:"Muslim", raw = TRUE)

readLines(file)

d<-read.csv(file)
docs_bulk(d, index = "idx_religion")

docs_get(index='idx_religion', type = 'rlgs', id=1)
