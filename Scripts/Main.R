# Main Script -------------------------------------------------------------
#| Script that sets up the workspace and call the remainder of scripts

# Set up ------------------------------------------------------------------
# set the wd as the base_path
base_path <- "C:/Users/PC/OneDrive - University of the Sunshine Coast/AniML"

set.seed(1000)
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

# Define variables
species <- "Sparkes_Koala"
sample_rate <- 50

# Functions ---------------------------------------------------------------
source(file = file.path(base_path, "Scripts", "PlottingFunctions.R"))

# Make the directories ----------------------------------------------------
dirs <- c(file.path(base_path, "Data", species, "raw"), # put the raw data in here
          file.path(base_path, "Data", species, "Diagnostics"), # here is where the data checking will save
          file.path(base_path, "Output", species) # this is where performance and models will be saved
          )
for (dirname in dirs){
  if (!dir.exists(dirname)){dir.create(dirname)}
}

# Format Data -------------------------------------------------------------
# This will be a custom script you write for your dataset that coerces it into the expected format
# Expected format: Time (as POSIXct), ID, Activity, FuncActivity (grouped activities), X, Y, Z
source(file = file.path(base_path, "Scripts", "DataFormatting", paste0(species, "_Formatting.R")))

# Explore data ------------------------------------------------------------
source(file = file.path(base_path, "Scripts", "ExploringData", "SequenceIdentificationFunctions.R"))
source(file = file.path(base_path, "Scripts", "ExploringData", "SequentialReport.R"))
source(file = file.path(base_path, "Scripts", "ExploringData", "ClusteringAnalysis.R"))

# Generate features -------------------------------------------------------
# When the data has been cleaned and the optimal behavioural labels determined
# generate features based on the following variables
window_length <- 2
overlap <- 0

source(file = file.path(base_path, "Scripts", "DataFormatting", "GenerateFeatures_Functions.R"))
source(file = file.path(base_path, "Scripts", "DataFormatting", "GenerateFeatures.R"))

# Tune and Test the model 3 times -----------------------------------------
# repeat the entire process 3 times for cross-validation
# assign IDs to their fold
data <- fread(file.path(base_path, "Data", species, "Feature_data.csv"))
unique_IDs <- unique(data$ID)
ID_groups <- data.frame(
  ID = unique_IDs,
  group = sample(rep(1:3, length.out = length(unique_IDs)))
)

source(file = file.path(base_path, "Scripts", "ModelBuilding", "PerformanceTestingFunctions.R"))
source(file = file.path(base_path, "Scripts", "ModelBuilding", "HPOFunctions.R"))
for (i in 1:3){
   print(i)
   # define the test IDs for this round
   test_IDs <- ID_groups$ID[ID_groups$group == i]
  
   # Make the Model ----------------------------------------------------------
   # tune, train, and test a model and generate predictions on the test data
   source(file = file.path(base_path, "Scripts", "ModelBuilding", "BuildModel.R"))
   # individual output saved rather than directly averaged to allow post-processing experiments
}

# Train the final model ---------------------------------------------------
# Take the average of the performance of the previous models and generate a final model
# This will be what's used on the unlabelled data
#TODO: Find better way of deciding on parameters rather than averaging
source(file = file.path(base_path, "Scripts", "ModelBuilding", "GenerateFinalModel.R"))

# Apply to the unlabelled data --------------------------------------------
# this will be different for every set up... to be determined based on the data setup
