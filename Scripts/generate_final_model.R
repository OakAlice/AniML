# Generate the final model, to be used on the unlabelled data -------------

if (!file.exists(file.path(base_path, "Output", species, "FinalModel.rda"))) {
  
  # read in the parameters from the 3 cross-validated models
  models <- list.files(file.path(base_path, "output", species), pattern = ".rds", full.names = TRUE)
  params <- lapply(models, function(x){
    mod <- readRDS(x)
    num.trees <- mod$num.trees
    mtry <- mod$mtry
    max.depth <- mod$max.depth
    variables <- mod$num.independent.variables
    
    data.frame("num.trees" = num.trees, "mtry" = mtry, "max.depth" = max.depth, "variables"= variables)
  })
  params <- rbindlist(params)
  
  # calculate the mean of these
  num.trees <- mean(params$num.trees)
  mtry <- mean(params$mtry)
  max.depth <- mean(params$max.depth)
  variables <- mean(params$variables)
  
  # clean the data
  data <- fread(file = file.path(base_path, "Data", species, "Feature_data.csv"))
  
  clean_cols <- clean_features(data, var_threshold = 0.3, corr_threshold = 0.9)
  data <- data %>%
    select(c(!!!syms(clean_cols), "Activity")) %>%
    na.omit() %>%
    mutate(Activity = as.factor(Activity))
  
  # weight by class frequency
  class_freq <- table(data$Activity)
  class_weights <- 1 / class_freq
  class_weights <- class_weights / sum(class_weights)
  weight <- class_weights[data$Activity]
  
  RF_model <- ranger(
    dependent.variable.name = "Activity",
    data = data,
    num.trees = num.trees,
    mtry = mtry,
    max.depth = max.depth,
    classification = TRUE,
    probability = TRUE,
    importance = "impurity",
    case.weights = weight
  )
  
  # save this model
  saveRDS(RF_model, file.path("Output", species, "FinalModel.rds"))
  
} else {
  print("final model already generated")
}
