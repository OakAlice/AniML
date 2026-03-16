# Code to generate features from all the data -----------------------------
available_axes <- c("X", "Y", "Z") # names of the axes

# Generate the features ---------------------------------------------------
if (file.exists(file.path(base_path, "Data", species, "Feature_data.csv"))){
  print("training features already generated")
} else {
  
  data1 <- fread(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))
  
  data1 <- data1 %>% group_by(ID, Activity) %>% arrange(Time)
  
  # generate the features
  generated_features <- list()
  for (id in unique(data1$ID)){
    
    if (file.exists(file.path(base_path, "Data", species, paste0(id, "_feature_data.csv")))){
      print("already calculated")
      feature_data <- fread(file.path(base_path, "Data", species, paste0(id, "_feature_data.csv")))
      
    } else {
      data <- data1 %>% 
      dplyr::filter(ID == id) %>% 
      as.data.table()
    
      window <- ifelse(sample_rate > 1, 2, 5) # to give it more data to work with 
      
      feature_data <- processDataPerID(data, 
                                       features_type = c("timeseries", "statistical"), 
                                       window_length = window, 
                                       sample_rate = sample_rate, 
                                       overlap_percent = overlap)
      
      # save the ID
      fwrite(feature_data, file.path(base_path, "Data", species, paste0(id, "_feature_data.csv")))
      
    }
    
    generated_features[[id]] <- feature_data
  }
  generated_features_df <- bind_rows(generated_features)
  fwrite(generated_features_df, file.path(base_path, "Data", species, "Feature_data.csv"))
}


