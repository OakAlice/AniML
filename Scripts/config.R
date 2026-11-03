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
species <- "Sparkes_Koala"
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
source(file = file.path("Scripts", "PlottingFunctions.R"))
source(file = file.path("Scripts", "DataFormatting", "GenerateFeatures_Functions.R"))
source(file = file.path("Scripts", "ModelBuilding", "PerformanceTestingFunctions.R"))
source(file = file.path("Scripts", "ModelBuilding", "HPOFunctions.R"))
