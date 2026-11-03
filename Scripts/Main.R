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
source(file = file.path("Scripts", "DataFormatting", paste0(species, "_Formatting.R")))

# Preprocessing -----------------------------------------------------------
data <- fread(file.path("Data", species, "Formatted_raw_data.csv"))
processed <- preprocessing(data)

# will include augmentation

# Generate features -------------------------------------------------------
features <- generate_features(processed, sample_rate, overlap_percent, window_length)
fwrite(features, file.path("Data", species, "Feature_data.csv"))

# Tune test possible models -----------------------------------------------
tuning_metrics <- tune_model(features)
# inspect the metrics to select final parameters



# Write to CSV
write.csv(metrics$metrics, file = file.path(base_path, "Data", species, paste0("Original_performance_metrics_", i, ".csv")), row.names = FALSE)
write.csv(predictions_df, file = file.path(base_path, "Data", species, paste0("Original_predictions_", i, ".csv")), row.names = FALSE)








# Train the final model ---------------------------------------------------
# Take the average of the performance of the previous models and generate a final model
# This will be what's used on the unlabelled data
#TODO: Find better way of deciding on parameters rather than averaging
source(file = file.path("Scripts", "ModelBuilding", "GenerateFinalModel.R"))


# Postprocessor -----------------------------------------------------------


# Apply to the unlabelled data --------------------------------------------
# this will be different for every set up... to be determined based on the data setup
