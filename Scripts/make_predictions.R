
# Function to make the predictions ----------------------------------------
generate_predictions <- function(model, model = 'RF', data){
  
  dt <- copy(data)
  
  clean_cols <- model$forest$independent.variable.names
  
  complete_cases <- dt %>% select(all_of(c(clean_cols, "ID", "Time"))) %>% na.omit()
  features <- complete_cases %>% select(all_of(clean_cols)) %>% as.matrix()
  metadata <- complete_cases %>% select(ID, Time)
  
  # Make predictions
  output <- predict(model, data = features)
  predictions <- output$predictions
  predicted_class <- colnames(predictions)[max.col(predictions, ties.method = "first")]
  predictions_df <- cbind(metadata, predictions, predicted_class)
  
  return(predictions_df)
}
