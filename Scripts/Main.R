# aniML: automated machine learning for animal behaviour classification ---
# Created by Oakleigh Wilson and Pranav Minasandra (2026)
# Intended for classifying animal behaviours from labelled accelerometer data

# Set up ------------------------------------------------------------------
# setwd("C:/Users/PC/OneDrive - University of the Sunshine Coast/AniML")
setwd("C:/Users/oaw001/OneDrive - University of the Sunshine Coast/AniML")
source("Scripts/config.R")

# Format Data -------------------------------------------------------------
# This will be a custom script you write for your dataset that coerces it into the expected format
# Expected format: Time (as POSIXct), ID, Activity, X, Y, Z
# source(file = file.path("Scripts", "DataFormatting", paste0(species, "_Formatting.R")))

# Relabelling -------------------------------------------------------------
# relabelling the classes if necessary (hasn't been done yet)

# Preprocessing -----------------------------------------------------------
data <- fread(file.path("Data", species, "Formatted_raw_data.csv"))
# processed <- preprocessing(data)
processed <- data

# will include augmentation

# Generate features -------------------------------------------------------
features <- generate_features(processed, sample_rate, overlap_percent, window_length)
fwrite(features, file.path("Data", species, "Feature_data.csv"))

# Tune test possible models -----------------------------------------------
tuning_metrics <- tune_model(features, k_folds = 3, inits = 2, rounds = 5, model = 'RF', bounds = 'default', optimisation_metric = 'F1')

# inspect the metrics to select final parameters... # I should figure out how to automate this... if it's even necessary
parameters <- list(mtry = 11, num_trees = 600, max_depth = 10)

# Train the final model ---------------------------------------------------
# This will be what's used on the unlabelled data
final_model <- generate_final_model(features, parameters)
saveRDS(final_model, file.path("Output", species, "Final_model.rds"))

# Postprocessor -----------------------------------------------------------





# Apply to the unlabelled data --------------------------------------------
# this will be different for every set up... to be determined based on the data setup
