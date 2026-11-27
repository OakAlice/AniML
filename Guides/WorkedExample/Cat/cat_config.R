# Config file for the AniML code ------------------------------------------

#install.packaged("pacman")
pacman::p_load(
  tidyverse, 
  data.table,
  caret,
  future,
  future.apply,
  zoo,
  lubridate,
  rlang,
  tsfeatures,
  rBayesianOptimization,
  ranger,
  matrixStats,
  signal,
  patchwork,
  umap,
  ggmap,
  Gmedian
)

# General variables ---------------------------------------------------------
species <- "GaleaCat"
available_axes <- c("X", "Y", "Z")
set.seed(1000)
target_class_list <- c("Locomotion", "Fast_Locomotion", "Rest")

# Feature variables ---------------------------------------------------------
scaling = FALSE
filtering = TRUE
rotating = TRUE

sample_rate <- 50
window_length <- 2
overlap_percent <- 0

# tuning variables ----------------------------------------------------------
tuning_k_folds <- 2
tuning_inits <- 5
tuning_rounds <- 5
model_architecture <- "RF"
tuning_bounds <- 'default'
optimisation_macro <- "Target-Macro-Average" # Macro-Average, Weighted-Average, Target-Macro-Average
optimisation_metric <- 'F1' # Accuracy, Precision, Recall, etc.

hpo_bounds <- list(
  mtry = c(2, 20),
  max_depth = c(5, 30),
  number_trees = c(100, 1000)
)

# Plotting layer ----------------------------------------------------------
cat_colours <- c(
  "Fast_Locomotion" = "coral",
  "Locomotion" = "gold1",
  "Feeding" = "aquamarine3",
  "Groom" = "darkseagreen4",
  "Unknown" = "plum",
  "Rest" = "deepskyblue3"
)
