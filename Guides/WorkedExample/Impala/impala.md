# Impala Worked Example

In this worked example, the default mode of the aniML package will be demonstrated, with no customisation. Data will be prepared, a model tuned and trained, and predictions made on the deployment data from a single day from a single impala.

## Dataset details
Collars were designed and built by Chris Bird, Robin Maag, and Jasmin Annett. Data was collected by Christofer Clemente, Jasmin Annett, Robin Maag, Chris Bird, and Taylor Dick. Training data was annotated by Amelia Nelson.

## Behavioural classification workthrough

Data are expected to be in format of 1 row per time observation, with columns ID, Time, Activity, and the triaxial accelerometer readings - X, Y, and Z. In this example, the data is already in the appropriate format.

### Exploration

<p align="center">
  <img src="https://github.com/OakAlice/AniML/blob/main/Guides/WorkedExample/Figs/plotTraceExample.png" alt="Examples from each behavioural class="30%">
</p>
<p align="center"><em>Fig 1: Examples from each behavioural class (row) from each individual (column) in the labelled data. Use this plot as a QA to check whether the behaviours confirm to expectation.</em></p>

### Preprocessing

The first stage is to prepare the accelerometer data for processing. Outliers, machine noise, and inonsistencies in collaring protocol (e.g., orientation of the devices) will make the process harder. Therefore, the first step is to standardise where possible.

In this case, units are all in the same scale and axes are all in the same orientation. Therefore, data only needs to be filtered to remove noise. 

Run the preprocessing function with the selected processing steps. If no variables are specified, a default processing will be applied.

```
processed <- preprocessing(data, sample_rate, filter = TRUE)
```

### Augmentation
If there are one or more ecologically important significantly underrepresented minority classes, these can be augmented to increase prevalance in the dataset. 

```
boosted <- boost_minority_classes(processed, features, target_classes = c("Fast_Locomotion"))
```

### Tuning, testing, and training
With the labelled data prepared, a model can now be tuned and cross-validated to obtain performance estimates.

If no variables are specified, the model will default to a Random Forest and will search a default hyperparameter space, optimising for the macro-average F1.

```
tuning_metrics <- tune_model(data = boosted)
```
Output from this function include confusion matrices, optimal parameters, and performance metrics for each of the folds. 

In this case, the performance of the impala model is around 0.62 macro-average F1.

<p align="center">
  <img src="https://github.com/OakAlice/AniML/blob/main/Guides/WorkedExample/Figs/confusionMatrix.png" alt="Example confusion matrix="30%">
</p>
<p align="center"><em>Fig 2: Example confusion matrix from one fold of the optimisation of the impala model. True class (as determined from the videos) are rows and predicted class (predicted by the model) are the columns. Values represent the number of true classes predicted per predicted class out of all true counts in that class. Colours represent percentage of each true class.</em></p>

Inspection of this confusion matrix suggests good performance for most behaviours but a high rate of confusion for Grooming (split between being predicted as foraging and walking). Similarly, walking is frequently predicted as foraging.

If performance is unexpectedly good, poor, or confusing, that may indicate inconsistencies in the labelled data.

If proceeding, generate the final model.

```
parameters <- tuning_metrics$parameters
chosen_parameters <- list(mtry = mean(parameters$mtry), num_trees = mean(parameters$num_trees), max_depth = mean(parameters$max_depth)) 

final_model <- generate_final_model(features, model = 'RF', chosen_parameters)
```

### Make predcitions
Finally, to apply this model to the unlabelled data, the unlabelled data must be preprocessed in the same way as the training data and then passed into the prediction function. If no variables are defined, the data will be processed in a default way. 

```
unlabelled_data <- fread("Guides/WorkedExample/Impala/ClementeImpala_unlabelled_example.csv") %>% select(-lat, -lon)
proc_unlabelled_data <- preprocessing(unlabelled_data, sample_rate)

final_output <- generate_predictions(proc_unlabelled_data,
                                     sample_rate, overlap_percent, window_length,
                                     final_model, 
                                     model_type = "RF")

```
These are now the final results.

### Ecological analysis
A few basic graphs can be generated.

<p align="center">
  <img src="https://github.com/OakAlice/AniML/blob/main/Guides/WorkedExample/Figs/behavioural_budget.png" alt="Behavioural budget="30%">
</p>
<p align="center"><em>Fig 3: Behavioural budget for one day of one impala showing the proportion of each behaviour per hour.</em></p>

<p align="center">
  <img src="https://github.com/OakAlice/AniML/blob/main/Guides/WorkedExample/Figs/day_in_a_life.png" alt="One day of an impala represented in coloured bars="30%">
</p>
<p align="center"><em>Fig 4: Behavioural sequence of one day of one impala, represented as behaviour per second across each hour (row).</em></p>
