# AniML

This repository contains a minimal pipeline for training, validating, and testing a Random Forest classifier on animal accelerometer data. The script includes data formatting, feature extraction, train-test splitting, and hyperparameter tuning for a limited set of hyperparameters. It is very simplistic. Mainly just to provide functions with suggested workflow. I'm still working on improving this and will continue to update it as I continue in my PhD.

Code written by Oakleigh Wilson in ~2024. For help or questions, contact my work email: **oakleigh.wilson@research.usc.edu.au**
Worked example provided. Example data sourced from [Vehkaoja et al., 2020](https://www.sciencedirect.com/science/article/pii/S2352340922000348) but only a very small amount of data commited to Git (otherwise too big).

---
## Folder structure

```
AniML/ 
├── Scripts/
│ ├── DataFormatting/
│ │ ├── GenerateFeatures_Functions.R
│ │ └── Vehkaoja_Dog_Formatting.R # this is the example I've done but create a new one for your data
│ └── ModelBuilding/
│   ├── HPOFunctions.R
│   ├── TestFunctions.R
│   └── TuneTrainTestModel.R
├── Data/
│ └── Vehkaoja_Dog/
|   ├── raw_data / # folder with all the raw data for that species # put this in
    # these next ones are created by the script
│   ├── Feature_data.csv # the features
│   ├── test_data.csv # split out hold-out test data
│   └── other_data.csv # split out non-test data
├── Output/ # this is what's created by the script
│ └── Vehkaoja_Dog/
│   ├── selected_hyperparameters.csv # the hyperparameters 
│   ├── Activity_model.rds
│   ├── Performance_metrics.csv
│   ├── Confusion_matrix.csv
│   └── Predictions.csv
└── Main.R
```

## Using this workflow
This is only a very minimal workflow with very minimal functionality. Many unique changes and choices will still need to be made to integrated into a specific study.

1. **Set Base Path**  
   Modify the base_path in `Main.R` to the location of your local project directory.
2. **Install Packages**  
   Uses the `pacman` package to load and install packages
3. **Define Variables**
    - species: dataset tag (e.g., "Vehkaoja_Dog")
    - sample_rate: sampling rate in Hz
    - desired_window: window size (in seconds)
    - desired_overlap: window overlap (percentage)
    - split_data_method: how to split your data ("individual" would be based on ID)
    - available_axes: e.g., c("X", "Y", "Z") are the names of your accelerometer axes. Can add more or use less.
4. **Format Data**
    The formatting script (species_Formatting.R) should be unique to you. I've made an example with the Vehkaoja_Dog data just to show what it should do.
    Basically, take your data from whatever raw format it begins in, and end up with columns: ID, Time, X, Y, Z, Activity
5. **Split off test data**
    Split out the test data based on whatever rule you want. I have it set to 40% of individuals are used for testing; 60% for training and validation. Saves these to the Data folder as well.
6. **Generate features for each ID**
    This generates the features from [Tatler et al., 2018](https://journals.biologists.com/jeb/article/221/23/jeb184085/20503/High-accuracy-at-low-frequency-detailed)as well as all features from the ['tsfeatures' R package](https://cran.r-project.org/web/packages/tsfeatures/vignettes/tsfeatures.html) for each individual at a time. 
7. **Tune, Train and Test a Model**
    - Trains and tests a model for each set of hyperparameters using 3-fold cross validation and then takes the average. Hyperparameter set that results in highest  weighted-average F1 score is suggested for the final model. Uses the non-test data to prevent leakage to the final test. Tunes based on Bayesian optimisation using rBayesianOptimization across bounds defined for:
        - mtry
        - max_depth
        - number_trees
    - Model Training: Trains a model with all non-test data using the hyperparameters suggested in the previous stage.
    - Tests Model: loads in the test data, runs the model on it, and tests. Saves performance metrics, predictions, and confusion matrix for closer analysis. 

**Notes**
- This is only immune to over-fitting when run once per species dataset. If tuning other parameters such as label clusterings or window length, etc., a larger nested workflow will have to be run.
- Models are weighted by class prevelance. You may want to change the way they are weighted, or initialise some kind of balancing between classes.
- Is not cross-validated outside of hyper-parameter tuning. If you want to add overall cross-validation, just wrap the whole workflow into a parant cross-validation flow.

