library(anytime)
library(lubridate)

#Function that transforms into dataset
transform_metadata_to_df <- 
  function(df){
    df[[1]] %>%  
      map(as_tibble) %>% 
      list_rbind() %>% 
      mutate(latestData = map_chr(latestData,1, .default = NA_character_)) %>% 
      mutate(latestData = as_datetime(latestData, tz = 'UTC')) %>% 
      unnest_wider(location) %>% 
      unnest_wider(latLon)
  }


#Adding a new function to_iso8601
to_iso8601 <- function(date_time, offset) {
  converted <- date_time + days(offset)
  iso8601_date_time <- format(converted, "%Y-%m-%dT%H:%M:%SZ")
  return(iso8601_date_time)
}
to_iso8601(as_datetime("2016-09-01 10:11:12"), -4)


#Adding a transform volumes function
transform_volumes <- function(json_data) {
  # Extract the 'edges' list which contains the data
  edges <- json_data$data$trafficData$volume$byHour$edges
  
  # Create a data frame with 'from', 'to', and 'volume' columns
  df <- data.frame(
    from = sapply(edges, function(edge) edge$node$from),
    to = sapply(edges, function(edge) edge$node$to),
    volume = sapply(edges, function(edge) edge$node$total$volumeNumbers$volume),
    stringsAsFactors = FALSE
  )
  
  # Transform the 'from' column to POSIXct date-time objects
  df$from <- as.POSIXct(df$from, format = "%Y-%m-%dT%H:%M:%S", tz = "GMT")
  
  # Return the transformed data frame
  return(df)
}
