# aniML: automated machine learning for animal behaviour classification ---
# Created by Oakleigh Wilson and Pranav Minasandra (2026)
# Intended for classifying animal behaviours from labelled accelerometer data

source("Scripts/config.R")

data <- fread(file.path("Data", species, "Formatted_raw_data.csv"))
unlabelled_data <- fread(file.path("Data", species, "Formatted_unlabelled_data.csv"))

# relabelling the classes if necessary (hasn't been done yet)

# processed <- preprocessing(data)

features <- generate_features(data, sample_rate, overlap_percent, window_length)

# boosted <- boost_minority_classes(processed, features)

tuning_metrics <- tune_model(features, 
                             k_folds = tuning_k_folds, inits = tuning_inits, rounds = tuning_rounds, 
                             model = model_architecture, bounds = tuning_bounds,
                             target_classes = target_class_list,
                             optimisation_macro, optimisation_metric)

parameters_all <- rbindlist(tuning_metrics$parameters)
parameters <- list(mtry = 2, num_trees = 500, max_depth = 15) # default option 

final_model <- generate_final_model(features, model = 'RF', parameters)

transition_probs <- generate_transition_probabilities(data, Hz = sample_rate)
transition_matrix <- transition_probs$transition_matrix
final_output <- generate_predictions(unlabelled_data,
                                     sample_rate, overlap_percent, window_length,
                                     final_model, model_type = model_architecture, 
                                     postprocessor = postprocessing_method, transition_matrix, 
                                     plot_sanity_check = TRUE)

eco_plots <- generate_ecological_plots(final_output$final_predictions)

methods_report <- generate_methods_report()
