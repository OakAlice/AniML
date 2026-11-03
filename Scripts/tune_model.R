# Master script for building the models for any given species etc ---------

tune_model <- function(features, k_folds = 3, model = 'RF', bounds = 'default', optimisation_metric = 'weighted_F1'){
  #' optimisation_metric (string | options: weighted_F1, F1, ROC_AUC): what the HPO is optimising for
  
  dt <- copy(features)
  
  ids <- unique(dt$ID)
  ID_groups <- data.frame(
    ID = ids,
    group = sample(rep(1:k_folds, length.out = length(ids)))
  )
  
  metrics <- vector("list", k_folds)
  parameters <- vector("list", k_folds) # blank list to store the results of the loop
  for (i in seq_len(k_folds)){
    
    test_IDs <- ID_groups$ID[ID_groups$group == i]
    test_data <- dt %>% dplyr::filter(ID %in% test_IDs)
    other_data <- dt %>% dplyr::filter(!ID %in% test_IDs)  
    
    # these are the default bounds to search if they haven't been explicitly defined
    if (model == 'RF' & bounds == 'default'){
      hpo_bounds <- list(
        mtry = c(2, 20),
        max_depth = c(5, 30),
        number_trees = c(100, 1000)
      )
    }
    
    results <- BayesianOptimization(
      FUN = function(number_trees, mtry, max_depth) {
        model_optimisation(
          feature_data = other_data,
          optimisation_metric = optimisation_metric,
          number_trees = number_trees,
          mtry = mtry,
          max_depth = max_depth
        )
      },
      bounds = hpo_bounds,
      init_points = 4,
      n_iter = 10,
      acq = "ucb",
      kappa = 2.576
    )
    
    # extract the best ones
    best_mtry <- round(results$Best_Par[["mtry"]],0)
    best_number_trees <- round(results$Best_Par[["number_trees"]],0)
    best_max_depth <- round(results$Best_Par[["max_depth"]],0)
    best_performance <- results$Best_Value # just for interest
    
    # prepare all of the training data
    clean_cols <- clean_features(other_data, var_threshold = 0.3, corr_threshold = 0.9)
    training_data <- other_data %>%
      select(c(!!!syms(clean_cols), "Activity")) %>%
      na.omit() %>%
      mutate(Activity = as.factor(Activity))
    
    # weight by class frequency
    class_freq <- table(training_data$Activity)
    class_weights <- 1 / class_freq
    class_weights <- class_weights / sum(class_weights)
    weight <- as.numeric(class_weights[as.character(training_data$Activity)])
    
    # make a model
    if (model == 'RF'){
      trained_model <- ranger(
        dependent.variable.name = "Activity",
        data = training_data,
        num.trees = best_number_trees,
        mtry = best_mtry,
        max.depth = best_max_depth,
        classification = TRUE,
        probability = TRUE,
        importance = "impurity",
        case.weights = weight
      )
    }
    
    # prepare the test data (features and metadata)
    complete_cases <- test_data %>% select(all_of(c(clean_cols, "Activity", "ID", "Time"))) %>% na.omit()
    test_features <- complete_cases %>% select(all_of(clean_cols)) %>% as.matrix()
    testing_metadata <- complete_cases %>% select(Activity, ID, Time)
    ground_truth_labels <- factor(testing_metadata$Activity)
    
    # Make predictions
    output <- predict(trained_model, data = test_features)
    predictions <- output$predictions
    lv <- colnames(predictions)
    predicted_class <- factor(lv[max.col(predictions, ties.method = "first")], levels = lv)
    predictions_df <- cbind(testing_metadata, predictions, predicted_class)
    
    fold_metrics <- compute_metrics(
      predicted_classes   = predictions_df$predicted_class,
      ground_truth_labels = factor(predictions_df$Activity, levels = lv)
    )
    
    fold_parameters <- data.frame(fold = i, mtry = best_mtry,
                                  num_trees = best_number_trees,
                                  max_depth = best_max_depth)
    
    # return everything from the fold
    metrics[[i]] <- fold_metrics$metrics
    parameters[[i]] <- fold_parameters
  }
  
  return(list(metrics = metrics, parameters = parameters))
}








# remove redundant and NA columns
clean_features <- function(feature_data, var_threshold, corr_threshold) {
  
  # Step 1: Calculate variance for numeric columns
  numeric_columns <- feature_data[, .SD, .SDcols = !names(feature_data) %in% c("Activity", "ID", "Time")]
  variances <- numeric_columns[, lapply(.SD, var, na.rm = TRUE)]
  selected_columns <- names(variances)[!is.na(variances) & variances > var_threshold]
  
  if (!length(selected_columns) > 2){
    selected_columns <- names(variances)[!is.na(variances)] # include all of them then
  }
  
  # Step 2: Remove highly correlated features
  numeric_columns <- numeric_columns[, ..selected_columns]
  corr_matrix <- cor(numeric_columns, use = "pairwise.complete.obs")
  high_corr <- findCorrelation(corr_matrix, cutoff = corr_threshold)
  remaining_features <- setdiff(names(numeric_columns), names(numeric_columns)[high_corr])
  
  return(remaining_features)
}

# main call that splits data, generates function, and validates
model_optimisation <- function(feature_data, optimisation_metric, number_trees, mtry, max_depth, k_folds){
  
  # remove bad features
  feature_data <- as.data.table(feature_data)
  clean_cols <- clean_features(feature_data, var_threshold = 0.3, corr_threshold = 0.9)
  clean_feature_data <- feature_data %>% select(c(!!!syms(clean_cols), "Activity", "ID", "Time")) %>% na.omit()
  
  if (mtry > length(clean_cols)-1){
    message("mtry too big, making max clean cols")
    flush.console()
    mtry <- length(clean_cols)
  }
  
  scores <- vector("list", k_folds)
  # Repeat the process 3 times
  for (i in seq_len(k_folds)) {
   
    tryCatch({
      # Create training and validation data, split by ID
      test_IDs <- sample(unique(clean_feature_data$ID), ceiling(0.3*length(unique(clean_feature_data$ID))))
      
      # Separate into training and testing
      validation_data <- clean_feature_data %>% dplyr::filter(ID %in% test_IDs)
      training_data <- clean_feature_data %>% dplyr::filter(!ID %in% test_IDs)                      
      training_data <- training_data %>% select(-c(ID, Time)) %>%  mutate(Activity = as.factor(Activity))
      validation_data <- validation_data %>% select(-c(ID, Time)) %>% mutate(Activity = as.factor(Activity))
      
    }, error = function(e) {
      message("Error in data splitting: ", e$message)
    })
    
    # Train RF model
    tryCatch({
      
      # weight by class frequency
      class_freq <- table(training_data$Activity)
      class_weights <- 1 / class_freq
      class_weights <- class_weights / sum(class_weights)
      weight <- class_weights[training_data$Activity]
      
      RF_model <- ranger(
        dependent.variable.name = "Activity",
        data = training_data,
        num.trees = number_trees,
        mtry = mtry,
        max.depth = max_depth,
        sample.fraction = 1, # select all the data (small datasets will fail otherwise)
        classification = TRUE,
        importance = "impurity",
        case.weights = weight
      )
      
    }, error = function(e) {
      message("Error in RF training: ", e$message)
      stop()
    })
    
    #### Validate the model
    tryCatch({
      numeric_validation_data <- as.matrix(validation_data[, !names(validation_data) %in% c("Activity"), with = FALSE])
      ground_truth_labels <- validation_data$Activity

      numeric_validation_data <- as.data.frame(numeric_validation_data)
      
      output <- predict(trained_model, data = test_features)
      predictions <- output$predictions
      lv <- colnames(predictions)
      predicted_class <- factor(lv[max.col(predictions, ties.method = "first")], levels = lv)
      predictions_df <- cbind(testing_metadata, predictions, predicted_class)
      
      fold_metrics <- compute_metrics(
        predicted_classes   = predictions_df$predicted_class,
        ground_truth_labels = factor(predictions_df$Activity, levels = lv)
      )
      
    }, error = function(e) {
      message("Error in making predictions: ", e$message)
      flush.console()
      stop()
    })
    
    # Store the F1 score
    scores[[i]] <- fold_metrics$metrics$F1[fold_metrics$metrics$Behaviour == "Macro-Average"]
  }
  
  #### Calculate average F1-scors
  # same NA problem
  final_scores <- unlist(scores)
  final_scores[is.na(final_scores)] <- 0 # set to 0 as penalty if missing
  average_macro <- mean(final_scores)
  
  # no preds for this one
  return(list(Score = average_macro, Pred = NA))
}

