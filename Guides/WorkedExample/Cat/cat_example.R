# Worked example using a domestic cat dataset ---------------------------------
# Dataset collected by Nicole Galea and Oakleigh Wilson
# Free-roaming domestic cats in australia, 2021
# in this example, we are going to use a customised versioning of the package with lots of variation

# SET UP ------------------------------------------------------------------
setwd("C:/Users/PC/OneDrive - University of the Sunshine Coast/05.AniML")
source("Scripts/config.R")
source("Guides/WorkedExample/impala_config.R")

# GENERATING TRAINING DATA ------------------------------------------------
data <- fread("Guides/WorkedExample/Cat/GaleaCat_labelled_raw.csv")

# basic visualisation
plotTraceExamples(data)
plotVolume(data, frequency = sample_rate, palette = aniML_colours)

processed <- preprocessing(data, sample_rate, rotate = rotating, 
                           rotation_ref_data = data[data$ID %in% c("Juliet", "Jett")])
plotTraceExamples(processed)

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
unlabelled_data <- fread("Guides/WorkedExample/Cat/GaleaCat_unlabelled_example.csv")
proc_unlabelled_data <- preprocessing(unlabelled_data, sample_rate, filter = filtering, rotate = rotating, 
                                                   rotation_ref_data = data[data$ID %in% c("Juliet", "Jett")])






final_output <- generate_predictions(proc_unlabelled_data,
                                     sample_rate, overlap_percent, window_length,
                                     final_model, 
                                     postprocessor = FALSE,
                                     model_type = model_architecture, 
                                     plot_sanity_check = FALSE)

# ECOLOGICAL ANALYSES -----------------------------------------------------
generate_ecological_plots(preds = final_output$final_predictions, palette = impala_colours)

# METHODS REPORT ----------------------------------------------------------
generate_methods_report()







# Just for me -------------------------------------------------------------
# making the datasets 
dat <- fread("D:/OurDatasets/Galea_Cat/Galea_Cat_Axivity/Coco_1.csv")
colnames(dat) <- c("Time", "X", "Y", "Z")
dat$ID <- "Coco"
dat$Time <- as.POSIXct((dat$Time - 719529)*86400, origin = "1970-01-01", tz = "UTC")
dat2 <- dat[as.Date(Time) == as.Date(Time)[3], ]
fwrite(dat2, "Guides/WorkedExample/Cat/GaleaCat_unlabelled_example.csv")

dat <- fread("D:/OurDatasets/Labelled/Galea_Cat/Galea_Cat_formatted.csv")
fwrite(dat, "Guides/WorkedExample/Cat/GaleaCat_labelled_raw.csv")
