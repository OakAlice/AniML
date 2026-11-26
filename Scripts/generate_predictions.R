
# Function to make the predictions ----------------------------------------
generate_predictions <- function(unlabelled_data,
                                 sample_rate, overlap_percent, window_length,
                                 final_model, model_type = 'RF', 
                                 postprocessor = NULL, transition_matrix = NULL, break_length = 3,
                                 plot_sanity_check = FALSE){
  
  unlabelled_features <- generate_features(unlabelled_data, sample_rate, overlap_percent, window_length)
  
  dt <- copy(unlabelled_features)
  
  clean_cols <- final_model$forest$independent.variable.names
  
  complete_cases <- dt %>% select(all_of(c(clean_cols, "ID", "Time"))) %>% na.omit()
  features <- complete_cases %>% select(all_of(clean_cols)) %>% as.matrix()
  metadata <- complete_cases %>% select(ID, Time)
  
  # Make predictions
  output <- predict(final_model, data = features)
  predictions <- output$predictions
  predicted_class <- colnames(predictions)[max.col(predictions, ties.method = "first")]
  predictions_df <- cbind(metadata, predictions, predicted_class)
  
  # make a postprocessor while we're here
  smoothed_predictions <- postprocessing(original_predictions = predictions_df, 
                                         method = "Bayesian",
                                         transition_matrix,
                                         break_length)
  
  # generate sanity check plots
  if(plot_sanity_check){
    plots <- sanity_check_plots(unlabelled_data, smoothed_predictions)
  } else {
    plots <- NULL
  }
  
  return(list(unlabelled_features = unlabelled_features,
              final_predictions = smoothed_predictions,
              plots = plots))
}

sanity_check_plots<- function(unlabelled_data, smoothed_predictions){
  #ugugughghghghghghh the plotting was SUCH a pain
  
  raw  <- as.data.table(unlabelled_data)   # copies, so the inputs aren't re-keyed by reference
  pred <- unique(as.data.table(smoothed_predictions)[, .(ID, Time, smoothed_class)],
                 by = c("ID", "Time"))
  
  setkey(raw,  ID, Time)
  setkey(pred, ID, Time)
  
  check <- pred[raw, roll = TRUE]
  setnames(check, "smoothed_class", "Activity")
  setcolorder(check, names(raw))
  
  sanity <- plotTraceExamples(behaviours = unique(check$Activity),
                              check, 
                              individuals = 1, n_samples = 6000, n_col = 3)
  
  # one palette, defined once up front
  beh_levels <- sort(unique(na.omit(check$Activity)))
  beh_cols   <- behaviour_colours[beh_levels]
  
  plots <- vector("list", 8)
  
  for (i in 1:4) {
    start <- sample.int(nrow(check) - 100000L, 1)
    dat   <- check[start:(start + 99999L)]
    
    dat[, run := rleid(Activity)]
    runs <- dat[, .(xmin = min(Time), xmax = max(Time), Activity = Activity[1]), by = run]
    
    # trace: no legend (X/Y/Z are fixed colours, state them in the caption)
    p_acc <- ggplot(dat, aes(x = Time)) +
      geom_path(aes(y = X, colour = "X")) +
      geom_path(aes(y = Y, colour = "Y")) +
      geom_path(aes(y = Z, colour = "Z")) +
      my_theme() +
      theme(axis.title = element_blank(), axis.text = element_blank(),
            legend.position = "none")
    
    # behaviour bar: the only legend
    p_beh <- ggplot(runs, aes(xmin = xmin, xmax = xmax, ymin = 0, ymax = 1, fill = Activity)) +
      geom_rect() +
      scale_fill_manual(name = "Behaviour", values = beh_cols,
                        limits = beh_levels, drop = FALSE) +
      my_theme() +
      theme(axis.title = element_blank(), axis.text = element_blank(),
            axis.ticks.y = element_blank())
    
    plots[[2 * i - 1]] <- p_acc
    plots[[2 * i]]     <- p_beh
  }
  
  design <- c(
    area(1,  1, 10, 1), area(11, 1, 11, 1),
    area(1,  2, 10, 2), area(11, 2, 11, 2),
    area(13, 1, 22, 1), area(23, 1, 23, 1),
    area(13, 2, 22, 2), area(23, 2, 23, 2)
  )
  
  grid <- wrap_plots(plots) +
    plot_layout(design = design, guides = "collect") &
    theme(legend.position = "bottom")
  
  return(list(all_behs = sanity,
              random_grid = grid))
  
}