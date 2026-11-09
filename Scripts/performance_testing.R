# Function for testing performance ----------------------------------------

# Plot of confusion matric ------------------------------------------------
generate_confusion_plot <- function(conf_matrix_padded) {
  
  # Extracting confusion matrix data and reshaping it
  conf_matrix_df <- as.data.frame(as.table(conf_matrix_padded))
  colnames(conf_matrix_df) <- c("Predicted", "Actual", "Count")
  
  # Repeat rows based on the Count column (i.e., add multiple rows for each count)
  conf_matrix_df_repeated <- conf_matrix_df[rep(1:nrow(conf_matrix_df), conf_matrix_df$Count), ]
  
  # Create a new column to classify the points as True Positive, False Positive, etc.
  conf_matrix_df_repeated$Type <- "Other"
  conf_matrix_df_repeated$Type[conf_matrix_df_repeated$Predicted == conf_matrix_df_repeated$Actual] <- "True Positive"
  conf_matrix_df_repeated$Type[conf_matrix_df_repeated$Predicted != conf_matrix_df_repeated$Actual] <- "False Positive"
  
  # Assign colors based on classification type
  conf_matrix_df_repeated$Color <- ifelse(conf_matrix_df_repeated$Type == "True Positive", "slateblue", "coral")
  
  # Plotting with jitter
  confusion_plot <- ggplot(conf_matrix_df_repeated, aes(x = Predicted, y = Actual, color = Color)) +
    geom_jitter(width = 0.1, height = 0.1, alpha = 0.3, size = 2) +  # Add jitter with fixed point size
    scale_color_manual(values = c("slateblue", "coral")) +
    labs(x = "Predicted Class", 
         y = "Actual Class") +
    my_theme() +
    theme(legend.position = "none")
  
  return(confusion_plot)
}

compute_metrics <- function(predicted_classes, ground_truth_labels, probabilities = NULL) {
  # Compute confusion matrix
  confusion_matrix <- table(predicted_classes, ground_truth_labels)
  all_classes <- union(levels(predicted_classes), levels(ground_truth_labels))
  
  # Create a padded confusion matrix (in case there are missing classes)
  conf_matrix_padded <- matrix(0, nrow = length(all_classes), ncol = length(all_classes),
                               dimnames = list(all_classes, all_classes))
  conf_matrix_padded[rownames(confusion_matrix), colnames(confusion_matrix)] <- confusion_matrix
  
  confusion_mtx <- caret::confusionMatrix(conf_matrix_padded)
  byClass <- confusion_mtx$byClass
  
  # If only 2 classes, convert named vector to 1-row matrix first
  if (is.null(dim(byClass))) {
    byClass <- t(as.matrix(byClass))
    rownames(byClass) <- colnames(conf_matrix_padded)[2]  # positive class
  }
  
  # threshold-free metrics (has to be one-vs-rest per class) 
  roc_auc <- setNames(rep(NA_real_, length(all_classes)), all_classes)
  pr_auc  <- setNames(rep(NA_real_, length(all_classes)), all_classes)
  
  if (!is.null(probabilities)) {
    probabilities <- as.matrix(probabilities)
    for (cl in intersect(all_classes, colnames(probabilities))) {
      y <- as.character(ground_truth_labels) == cl
      p <- probabilities[, cl]
      
      roc_auc[cl] <- tryCatch(
        as.numeric(pROC::auc(pROC::roc(response = y, predictor = p,
                                       levels = c(FALSE, TRUE), direction = "<",
                                       quiet = TRUE))),
        error = function(e) NA_real_)
      
      pr_auc[cl] <- tryCatch(
        PRROC::pr.curve(scores.class0 = p[y], scores.class1 = p[!y])$auc.integral,
        error = function(e) NA_real_)
    }
  }
  
  # byClass rownames are "Class: X"; strip to match probability column names
  cls_names <- sub("^Class: ", "", rownames(byClass))
  
  metrics <- data.frame(
    Behaviour  = rownames(byClass),
    Precision  = byClass[, "Precision"],
    Recall     = byClass[, "Recall"],
    F1         = byClass[, "F1"],
    Accuracy   = byClass[, "Balanced Accuracy"],
    ROC_AUC    = unname(roc_auc[cls_names]),
    PR_AUC     = unname(pr_auc[cls_names]),
    Prevelance = byClass[, "Prevalence"] * length(predicted_classes),
    row.names  = NULL
  )
  
  # Fill NAs with 0 for threshold metrics only (so the model can't cheat by not
  # predicting a class). AUCs are left as NA if undefined (class absent from test
  # data) and excluded from the macro-average via na.rm.
  thr_cols <- c("Precision", "Recall", "F1", "Accuracy")
  metrics[thr_cols][is.na(metrics[thr_cols])] <- 0
  
  # Macro-average as the last row
  metrics <- rbind(
    metrics,
    data.frame(
      Behaviour  = "Macro-Average",
      Precision  = mean(metrics$Precision),
      Recall     = mean(metrics$Recall),
      F1         = mean(metrics$F1),
      Accuracy   = mean(metrics$Accuracy),
      ROC_AUC    = if (all(is.na(metrics$ROC_AUC))) NA_real_ else mean(metrics$ROC_AUC, na.rm = TRUE),
      PR_AUC     = if (all(is.na(metrics$PR_AUC)))  NA_real_ else mean(metrics$PR_AUC,  na.rm = TRUE),
      Prevelance = NA
    )
  )
  
  return(list(metrics = metrics,
              conf_matrix_padded = conf_matrix_padded))
}