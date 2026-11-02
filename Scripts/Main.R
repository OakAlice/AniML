# Main Script -------------------------------------------------------------
# Executing the AniML code

# Set up ------------------------------------------------------------------
setwd("C:/Users/PC/OneDrive - University of the Sunshine Coast/AniML")

# Format Data -------------------------------------------------------------
# This will be a custom script you write for your dataset that coerces it into the expected format
# Expected format: Time (as POSIXct), ID, Activity, FuncActivity (grouped activities), X, Y, Z
source(file = file.path("Scripts", "DataFormatting", paste0(species, "_Formatting.R")))

# Explore data ------------------------------------------------------------
# source(file = file.path("Scripts", "ExploringData", "SequentialReport.R"))
# source(file = file.path("Scripts", "ExploringData", "ClusteringAnalysis.R"))

# Generate features -------------------------------------------------------
source(file = file.path("Scripts", "DataFormatting", "GenerateFeatures.R"))

# Tune and Test the model 3 times -----------------------------------------
# repeat the entire process 3 times for cross-validation
# assign IDs to their fold
data <- fread(file.path("Data", species, "Feature_data.csv"))
unique_IDs <- unique(data$ID)
ID_groups <- data.frame(
  ID = unique_IDs,
  group = sample(rep(1:3, length.out = length(unique_IDs)))
)

for (i in 1:3){
   print(i)
   # define the test IDs for this round
   test_IDs <- ID_groups$ID[ID_groups$group == i]
  
   # Make the Model ----------------------------------------------------------
   # tune, train, and test a model and generate predictions on the test data
   source(file = file.path("Scripts", "ModelBuilding", "BuildModel.R"))
   # individual output saved rather than directly averaged to allow post-processing experiments
}

# Train the final model ---------------------------------------------------
# Take the average of the performance of the previous models and generate a final model
# This will be what's used on the unlabelled data
#TODO: Find better way of deciding on parameters rather than averaging
source(file = file.path("Scripts", "ModelBuilding", "GenerateFinalModel.R"))

# Apply to the unlabelled data --------------------------------------------
# this will be different for every set up... to be determined based on the data setup
