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

available_axes <- c("X", "Y", "Z")
species <- "Annett_Kangaroo"
sample_rate <- 50
window_length <- 2
overlap_percent <- 0
set.seed(1000)

hpo_bounds <- list(
  mtry = c(2, 20),
  max_depth = c(5, 30),
  number_trees = c(100, 1000)
)

# Functions ---------------------------------------------------------------
source(file = file.path("Scripts", "generate_features.R"))
source(file = file.path("Scripts", "preprocessing.R"))
source(file = file.path("Scripts", "performance_testing.R"))
source(file = file.path("Scripts", "generate_final_model.R"))
source(file = file.path("Scripts", "tune_model.R"))
source(file = file.path("Scripts", "make_predictions.R"))

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
my_colours = c("grey37",
               "coral", 
               "goldenrod2", 
               "khaki2", 
               "aquamarine3", 
               "powderblue", 
               "plum", 
               "lightpink1")
