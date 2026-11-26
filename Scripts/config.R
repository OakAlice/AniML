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
  matrixStats
)

# General variables ---------------------------------------------------------
species <- "Annett_Kangaroo"
available_axes <- c("X", "Y", "Z")
set.seed(1000)
target_class_list <- NULL

# Feature variables ---------------------------------------------------------
sample_rate <- 50
window_length <- 2
overlap_percent <- 0

# tuning variables ----------------------------------------------------------
tuning_k_folds <- 3
tuning_inits <- 5
tuning_rounds <- 5
model_architecture <- "RF"
tuning_bounds <- 'default'
optimisation_macro <- "Macro-Average" # Weighted-Average, Target-Macro-Average
optimisation_metric <- 'F1' # Accuracy, Precision, Recall, etc.

hpo_bounds <- list(
  mtry = c(2, 20),
  max_depth = c(5, 30),
  number_trees = c(100, 1000)
)

# Postprocessing variables --------------------------------------------------
postprocessing_method <- "Bayesian"

# Functions ---------------------------------------------------------------
source(file = file.path("Scripts", "exploration_plots.R"))
source(file = file.path("Scripts", "generate_features.R"))
source(file = file.path("Scripts", "preprocessing.R"))
source(file = file.path("Scripts", "performance_testing.R"))
source(file = file.path("Scripts", "generate_final_model.R"))
source(file = file.path("Scripts", "tune_model.R"))
source(file = file.path("Scripts", "make_predictions.R"))
source(file = file.path("Scripts", "methods_report.R"))
source(file = file.path("Scripts", "ecological_analyses.R"))

# Plot stuff --------------------------------------------------------------
my_theme <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.border = element_rect(color = "black", linewidth = 1.5, fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.background = element_blank(),
      panel.background = element_blank(),
      axis.line = element_line(color = "black"),
      axis.ticks = element_line(color = "black")
    )
}

# Colours -----------------------------------------------------------------
aniML_colours <- c("grey37",
                  "firebrick3", "coral", "goldenrod2", "khaki2", 
                  "aquamarine3", "darkcyan", "gold1",
                  "springgreen3", "darkseagreen4", "turquoise2", "powderblue", "deepskyblue3", "slateblue2",
                  "mediumpurple3", "mediumorchid",
                  "plum", "lightpink1", "lavenderblush2")
