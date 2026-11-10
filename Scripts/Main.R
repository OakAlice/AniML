# aniML: automated machine learning for animal behaviour classification ---
# Created by Oakleigh Wilson and Pranav Minasandra (2026)
# Intended for classifying animal behaviours from labelled accelerometer data

# Set up ------------------------------------------------------------------
# setwd("C:/Users/PC/OneDrive - University of the Sunshine Coast/AniML")
setwd("C:/Users/oaw001/OneDrive - University of the Sunshine Coast/AniML")
source("Scripts/config.R")

# Expected format for data is data.table with 1 row per time observation
# Columns: ID, Time, Activity, X, Y, Z
data <- fread(file.path("Data", species, "Formatted_raw_data.csv"))

# Relabelling -------------------------------------------------------------
# relabelling the classes if necessary (hasn't been done yet)

# Preprocessing -----------------------------------------------------------
# processed <- preprocessing(data)

# Augment minority classes ------------------------------------------------
# boosted <- boost_minority_classes(processed)
boosted <- data

# Generate features -------------------------------------------------------
features <- generate_features(boosted, sample_rate, overlap_percent, window_length)
fwrite(features, file.path("Data", species, "Feature_data.csv"))

# Tune test possible models -----------------------------------------------
tuning_metrics <- tune_model(features, k_folds = 3, inits = 2, rounds = 5, model = 'RF', bounds = 'default', optimisation_metric = 'F1')

# inspect the metrics to select final parameters... # I should figure out how to automate this... if it's even necessary
# parameters <- list(mtry = 11, num_trees = 600, max_depth = 10)
parameters <- list(mtry = 2, num_trees = 500, max_depth = 15) # default option 

# Train the final model ---------------------------------------------------
# This will be what's used on the unlabelled data
final_model <- generate_final_model(features, model = 'RF', parameters)
saveRDS(final_model, file.path("Output", species, "Final_model.rds"))

# Make predictions on unlabelled data -------------------------------------
# data is expected to be in the same format as the labelled training data (except no Activity column)
# if the deployment was long, likely need to process one ID * week combo at a time.
unlabelled_data <- fread(file.path("Data", species, "Formatted_unlabelled_data.csv"))
unlabelled_features <- generate_features(unlabelled_data, sample_rate, overlap_percent, window_length)
fwrite(unlabelled_features, file.path("Data", species, "Unlabelled_Feature_data.csv"))

final_predictions <- generate_predictions(final_model, model = 'RF', unlabelled_features)
fwrite(final_predictions, file.path("Data", species, "Unlabelled_predictions.csv"))

# Postprocessor -----------------------------------------------------------







# Apply to the unlabelled data --------------------------------------------
# this will be different for every set up... to be determined based on the data setup
