library(jsonlite)
library(rjson)
library(RCurl)
library(RJSONIO)
library(dplyr)
library(tidyr)
library(tidyjson)
library(gsubfn)
library(lazyeval)

metaDef = read_json ("C:/work/4d-time-series-visualiser/metaDef.json")

metaDef_file <-metaDef %>% enter_object("file") %>% 
  spread_values(wrk_dir = jstring("wrk_dir"))

setwd(metaDef_file$wrk_dir)

buildData = read_json("data/buildResults.json")

axis_param <- c("time_axis", "z_axis", "y_axis", "x_axis", "bubble_axis")

metaData_path <- metaDef %>% enter_object("axis_paths") %>%
  spread_values(
    time_axis = jstring("time_axis"),
    z_axis = jstring("z_axis"),
    y_axis = jstring("y_axis"),
    x_axis = jstring("x_axis"),
    bubble_axis = jstring("bubble_axis"))

metaData_agg <- metaDef %>% enter_object("aggs")  

metaData_agg_keys<- metaData_agg %>% gather_keys()

time_axis_data <- getAxisData(buildData, metaData_path$time_axis, axis_param[1], metaData_agg)
z_axis_data <- getAxisData(buildData, metaData_path$z_axis, axis_param[2],metaData_agg)
y_axis_data <- getAxisData(buildData,metaData_path$y_axis, axis_param[3],metaData_agg)
x_axis_data <- getAxisData(buildData,metaData_path$x_axis, axis_param[4],metaData_agg)
bubble_axis_data <- getAxisData(buildData,metaData_path$bubble_axis, axis_param[5],metaData_agg)


join_axis_data <- inner_join(time_axis_data,z_axis_data) %>% 
  inner_join (.,y_axis_data) %>%
  inner_join(.,x_axis_data) %>%
  inner_join(.,bubble_axis_data) %>%
  tbl_df

df_build_data <- select(join_axis_data, time_axis_value, z_axis_value, y_axis_value, x_axis_value, bubble_axis_value)

write.csv(as.matrix(df_build_data),"data/axisData.csv",row.names = F)


###function to get the last character of a string ###

getLastChar <- function(data)
{
  return (substr(data, nchar(data),nchar(data)))
}


### function to get the aggregate parameters specified in the meta file ###
getAggParams = function(m_agg, p_axis)
{
  ###grouping field
  
  axis_obj <- m_agg %>% enter_object(p_axis) 
  
  paramNames <- c("groupByParam", "funParam", "fieldParam")
  
  groupBy_name <- axis_obj %>% enter_object("terms") %>% 
    spread_values( field = jstring("field") )
  
  ### function field and type
  fun_obj <- axis_obj %>% enter_object("aggs") %>% gather_keys
  
  fun_name <- axis_obj %>% enter_object("aggs") %>% 
    enter_object(fun_obj$key) %>% 
    spread_values( field_n = jstring("field"))
  
  
  paramValues <- c(groupBy_name$field, fun_obj$key, fun_name$field_n)
  
  aggParams <-  setNames(as.list(paramValues), paramNames)
  
  return(aggParams)
  
}

### function to aggregare the data based on the aggregate parameters ###
getAxisData_agg = function(query, groupBy_vars, aggParams, p_axis)
{
  groupBy_vars_dots = sapply(groupBy_vars, . %>% 
  {as.formula(paste0('~', .))})
  funField <- aggParams$fieldParam
  funName <- aggParams$funParam
  
  if (funName == "sum")
  {
    query_agg <- query %>% group_by_(.dots = groupBy_vars_dots)   %>%
      summarise_(.dots = fn$list(val = "sum(as.numeric($funField))"))
  }
  
  if(funName == "count")
  {
    query_agg <- query %>% group_by_(.dots = groupBy_vars_dots)   %>%
      summarise(val = n()) 
  }
  
  if(funName == "count_distinct")
  {
    query_agg <- query %>% group_by_(.dots = groupBy_vars_dots)   %>%
      summarise(val = n_distinct()) 
  }
  
  if (funName == "mean")
  {
    query_agg <- query %>% group_by_(.dots = groupBy_vars_dots)   %>%
      summarise_(.dots = fn$list(val = "mean(as.numeric($funField))"))
  }
  
  if (funName == "min")
  {
    query_agg <- query %>% group_by_(.dots = groupBy_vars_dots)   %>%
      summarise_(.dots = fn$list(val = "min(as.numeric($funField))"))
  }
  
  if (funName == "max")
  {
    query_agg <- query %>% group_by_(.dots = groupBy_vars_dots)   %>%
      summarise_(.dots = fn$list(val = "max(as.numeric($funField))"))
  }
  
  if (funName == "quantile")
  {
    query_agg <- query %>% group_by_(.dots = groupBy_vars_dots)   %>%
      summarise_(.dots = fn$list(val = "quantile(as.numeric($funField))"))
  }
  
  
  names(query_agg)[names(query_agg) == "val"] <- paste0(p_axis,"_value")
  
  return(query_agg)
}

### main function that extracts the value from the json file ###
getAxisData = function(buildData, m_data, p_axis,m_agg)
{
  query = NULL
  
  axis_v <- unlist(strsplit(m_data, "->"))
  
  axis_length <- length(axis_v)
  
  m_agg_keys <- m_agg %>% gather_keys()
  
  aggRequired <- FALSE
  group_by_values_complete <- FALSE
  groupBy_vars <- c()
  
  if (is.element(p_axis, m_agg_keys$key))
  {
    
    aggRequired <- TRUE
    
    aggParams <- getAggParams(m_agg, p_axis)
    
    groupBy_name <-  aggParams$groupByParam
    fun_name <- aggParams$funParam
    fun_field <- aggParams$fieldParam
  }
  
  for (i in 1:axis_length)
  {
    element = trimws(axis_v[i])
    
    if( i == 1)
    {
      query <- buildData
    }
    
    lastChar <- getLastChar(element)
    
    
    if (i==axis_length)
    {
      query <- query %>% spread_values( val = jstring(element))
      
      if(aggRequired)
      {
        names(query)[names(query) == "val"] <- fun_field 
      }
      else
      {
        names(query)[names(query) == "val"] <- paste0(p_axis,"_value")
      }
    }
    
    else 
    {
      if( lastChar != '*')
      {
        query <- query %>% enter_object(element)
      }
      else 
      {
        element <- substr(element,1,nchar(element)-1)
        index <- paste0(element, "_", i,"_index")
        query <-  query %>% enter_object(element) %>% gather_array(index)
        
        if(aggRequired && is.element(element, groupBy_name))
        {
          group_by_values_complete = TRUE
        }
        
        if(aggRequired && !group_by_values_complete)
        {
          groupBy_vars <- c(groupBy_vars, index)
        }
      }
    }
  }
  
  if(aggRequired)
  {
    
    query <- getAxisData_agg(query, groupBy_vars, aggParams, p_axis)
  }
  
  return (query)
}
