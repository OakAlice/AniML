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
  ranger
)

available_axes <- c("X", "Y", "Z")
species <- "Sparkes_Koala"
sample_rate <- 50
window_length <- 2
overlap <- 0
set.seed(1000)

# Functions ---------------------------------------------------------------
source(file = file.path("Scripts", "PlottingFunctions.R"))
source(file = file.path("Scripts", "DataFormatting", "GenerateFeatures_Functions.R"))
source(file = file.path("Scripts", "ModelBuilding", "PerformanceTestingFunctions.R"))
source(file = file.path("Scripts", "ModelBuilding", "HPOFunctions.R"))
source(file = file.path("Scripts", "ExploringData", "SequenceIdentificationFunctions.R"))

# Make the directories ----------------------------------------------------
dirs <- c(file.path("Data", species, "raw"), # put the raw data in here
          file.path("Data", species, "Diagnostics"), # here is where the data checking will save
          file.path("Output", species) # this is where performance and models will be saved
)
for (dirname in dirs){
  if (!dir.exists(dirname)){dir.create(dirname)}
}
