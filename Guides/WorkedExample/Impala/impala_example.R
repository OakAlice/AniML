# Worked example using an impala dataset ---------------------------------
# Dataset collected by Christofer Clemente, Jasmin Annett, and Robin Maag
# Free-roaming impala in south africa, 2024
# in this example, we are going to use the default versioning of the package with little/no customisation

# SET UP ------------------------------------------------------------------
setwd("C:/Users/PC/OneDrive - University of the Sunshine Coast/05.AniML")
source("Scripts/config.R")
source("Guides/WorkedExample/impala_config.R")

# GENERATING TRAINING DATA ------------------------------------------------
data <- fread("Guides/WorkedExample/Impala/ClementeImpala_labelled_raw.csv")

# basic visualisation
plotTraceExamples(data)
plotVolume(data, frequency = sample_rate)

processed <- preprocessing(data, sample_rate, filter = filtering)

features <- generate_features(processed, sample_rate, overlap_percent, window_length)

# boosted <- boost_minority_classes(processed, features, target_class)
boosted <- features

# MODEL TUNING AND TRAINING --------------------------------------------
tuning_metrics <- tune_model(boosted, 
                             k_folds = tuning_k_folds, 
                             inits = tuning_inits, 
                             rounds = tuning_rounds, 
                             model = model_architecture, 
                             bounds = tuning_bounds,
                             target_classes = target_class_list,
                             optimisation_macro, 
                             optimisation_metric
                             )

parameters <- tuning_metrics$parameters
chosen_parameters <- list(mtry = mean(parameters$mtry), num_trees = mean(parameters$num_trees), max_depth = mean(parameters$max_depth)) 

final_model <- generate_final_model(features, model = 'RF', chosen_parameters)

# MAKE PREDICTIONS --------------------------------------------------------
# TODO: Should I include the preprocessing in the wrapper?
unlabelled_data <- fread("Guides/WorkedExample/Impala/ClementeImpala_unlabelled_example.csv") %>% select(-lat, -lon)
proc_unlabelled_data <- preprocessing(unlabelled_data, sample_rate)

final_output <- generate_predictions(proc_unlabelled_data,
                                     sample_rate, overlap_percent, window_length,
                                     final_model, 
                                     model_type = model_architecture, 
                                     plot_sanity_check = FALSE)

# ECOLOGICAL ANALYSES -----------------------------------------------------
generate_ecological_plots(preds = final_output$final_predictions, palette = impala_colours)

# METHODS REPORT ----------------------------------------------------------
generate_methods_report()








# Code just for me, remove later ------------------------------------------
# this is for making the data I use in the case studies
# spare code

unlabelled_data <- fread("~/ImpalaProject/Data/RawData/Collar_5/Chunked/Board_Aligned_2024-07-08.csv") %>% 
  rename(Time = utc_datetime, X = RawAX.sc, Y = RawAY.sc, Z = RawAZ.sc) %>%
  mutate(ID = "Collar_5") %>%
  select(ID, Time, X, Y, Z, lon, lat)
fwrite(unlabelled_data, "Guides/WorkedExample/Impala/ClementeImpala_unlabelled_example.csv")

dat <- fread("~/ImpalaProject/Data/LabelledData/CleanedLabelledData.csv") %>%
  rename(X = RawAX.sc, Y = RawAY.sc, Z = RawAZ.sc) %>%
  select(Time, ID, X, Y, Z, Activity) %>%
  mutate(Activity = ifelse(Activity %in% c("Stationary_Vigilance", "Stationary_Standing", "Stationary_Sleep"), "Stationary", Activity))
fwrite(dat, "Guides/WorkedExample/Impala/ClementeImpala_labelled_raw.csv")
