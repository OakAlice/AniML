# Formatting the Sparkes_Koala data ---------------------------------------
output_path <- file.path(base_path, "Data", species, "Formatted_raw_data.csv")
# Read in and rename the data ---------------------------------------------
if(!file.exists(output_path)){
  
  data <- fread(file.path(base_path, "Data/Sparkes_Koala/raw/labelled_data.csv"))
  
  data <- data %>% 
    dplyr::rename(X = Accelerometer.X,
                  Y = Accelerometer.Y,
                  Z = Accelerometer.Z) %>%
    select(Time, ID, X, Y, Z, Activity)
  
  # Recode the behaviours into clusters -------------------------------------
  data <- data %>%
    mutate(FuncActivity = case_when(
      
      # Climbing
      Activity %in% c(
        "Rapid Climbing",
        "Climbing Down",
        "Climbing Up"
      ) ~ "Climbing",
      
      # General Movement in tree
      Activity %in% c(
        "Branch Walking",
        "Swinging/Hanging",
        "Tree Movement"
      ) ~ "Tree_Movement",
      
      #Maintainence
      Activity %in% c(
        "Grooming",
        "Shake"
      ) ~ "Grooming",
      
      # Inactivity
      Activity %in% c(
        "Sleeping/Resting",
        "Tree Sitting"
      ) ~ "Inactivity",
      
      # Eating
      Activity == "Foraging/Eating" ~ "Eating",
      # walking
      Activity == "Walking" ~ "Walking"
    )) %>%
    mutate(BroadActivity = case_when(
      FuncActivity %in% c(
        "Climbing",
        "Tree_Movement",
        "Grooming",
        "Eating"
      ) ~ "Tree_Movement",
      FuncActivity == "Inactivity" ~ "Inactivity",
      FuncActivity == "Walking" ~ "Walking"
    ))
  
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)  
  
} else {
  print("data already created")
}