# Vehkaoja_Dog ------------------------------------------------------------
# there is no time in this data (nor in the original data)
# therefore for "time" I've just grouped it into tests, presuming that everything in the test is continuous 

## Basic formatting -------------------------------------------------------
# this will be different for every dataset

if(!file.exists(file.path("Data", species, "Formatted_raw_data.csv"))){
  
  # i just stitch the data together
  files <- list.files(file.path("Data", species, "raw_data"), recursive = TRUE, full.names = TRUE)
  raw_data <- lapply(files, function(file) {
    df <- fread(file)
    df <- df %>% mutate(Time = row_number())
    return(df)
  }) 
  raw_data <- bind_rows(raw_data)
  
  # and thenI select the columns I want and give them the names that match my workflow
  raw_data <- raw_data %>%
    select(V13, Time, V4, V5, V6, V14) %>%
    rename(ID = V13,
           X = V4,
           Y = V5,
           Z = V6,
           Activity = V14)
  
  # save this 
  fwrite(raw_data, file.path("Data", species, "Formatted_raw_data.csv"))
  
} else {
  print("training data already formatted")
}
  
## Generate features ------------------------------------------------------
if (file.exists(file.path("Data", species, "Feature_data.csv"))){
  print("training features already generated")
} else {
    
  data1 <- fread(file.path("Data", species, "Formatted_raw_data.csv"))
    
  generated_features <- list()
  for (id in unique(data1$ID)){
    data <- data1 %>% 
      filter(ID == id) %>% 
      filter(!Activity == "") %>% 
      as.data.table()
      
    feature_data <- processDataPerID(data, 
                                     features_type = c("timeseries", "statistical"), 
                                     window_length = desired_window, # this is in seconds, 
                                     sample_rate = sample_rate, 
                                     overlap_percent = desired_overlap)
      
    generated_features[[id]] <- feature_data
    fwrite(feature_data, file.path("Data", species, paste0(id, "_feature_data.csv")))
  }
  generated_features_df <- bind_rows(generated_features)
  fwrite(generated_features_df, file.path("Data", species, "Feature_data.csv"))
}
  