# Methods report ----------------------------------------------------------
# pulling from the entire aniML codebase to generate a summary of the methods used for this analysis
# deviations and customisations of the code will require similar customisation of this code

generate_methods_report <- function(){
  
  # TODO: Add in the parameters that were ultimately selected for the final model... chosen_parameters
  
  est_performance <- mean(tuning_metrics$metrics[Behaviour == optimisation_macro, .(fold, value = get(optimisation_metric))]$value)
  sd_performance <- sd(tuning_metrics$metrics[Behaviour == optimisation_macro, .(fold, value = get(optimisation_metric))]$value)
  
  table_summary <- data.table(
    Variable = c("Individuals", "N_behaviours", "Behaviours", "Total_volume_mins", "Target_classes",
                 # feature variables
                 "Frequency_Hz", "Window_length_sec", "Overlap_percent",
                 # tuning variables
                 "Tuning_k_folds", "Tuning_inits", "Tuning_rounds",
                 "Model_architecture", "Tuning_bounds",
                 "Optimisation_macro", "Optimisation_metric",
                 # performance summary
                 "Est_performance", "Est_performance_sd",
                 # postprocessing variables
                 "Postprocessing_method"),
    Value = as.character(c(
      uniqueN(data$ID),
      uniqueN(data$Activity),
      paste(sort(unique(data$Activity)), collapse = ", "),
      round(nrow(data) / sample_rate / 60, 1),
      paste(sort(unique(target_class_list)), collapse = ", "),
      sample_rate,
      window_length,
      overlap_percent,
      tuning_k_folds,
      tuning_inits,
      tuning_rounds,
      model_architecture,
      tuning_bounds,
      optimisation_macro,
      optimisation_metric,
      round(est_performance,2),
      round(sd_performance,2),
      postprocessing_method
    ))
  )
  
  written_summary <- with(as.list(setNames(table_summary$Value, table_summary$Variable)), paste0(
    "Training data contained ", Total_volume_mins, " minutes of ", Frequency_Hz, " Hz accelerometer data from ",
    Individuals, " individual(s), covering the ", N_behaviours, " behaviours: ", Behaviours, ".\n",
    "Summary features were generated across a ", Window_length_sec, " s windows with ", Overlap_percent, "% overlap.\n",
    "A ", Model_architecture, ", model was tuned with ", Tuning_k_folds, "-fold cross-validation. \n",
    "Bayesian hyperparamter optimisation optimised for ", Optimisation_macro, " ", Optimisation_metric, " across ",
    Tuning_inits, " initial points and ", Tuning_rounds, " optimisation rounds (bounds: ",
    Tuning_bounds, ").",
    if (!is.null(target_class_list)) paste0(" Specifically performance was optimised for the target classes: ", Target_classes, "."),
    "\n",
    "The cross-validated estimated performance of the model was ", Est_performance, " +/- ",  Est_performance_sd,". \n",
    "Further smoothing was applied with ", Postprocessing_method, " postprocessing."
  ))
  
  return(list(table_summary = table_summary,
              written_summary = written_summary))
}
