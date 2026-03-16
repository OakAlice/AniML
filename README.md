# AniML

This repository contains a minimal pipeline for developing a supervised machine learning animal behaviour classifier. 

![Workflow](/Figures/Workflow.png)

1. Initial data exploration scripts used to determine optimal behavioural clusters. *[In Progress]*
2. Machine learning scripts used for training, validating, and testing classifier (includ. data formatting, feature extraction, train-test splitting, and hyperparameter tuning for a limited set of hyperparameters for either multi-class Random Forest or binary-class SVMs). *[Complete]*
3. Prediction results can be plugged into post-processing workflow developed [here](https://github.com/OakAlice/PostProcessing). *[Complete]*
4. To reconstruct exact movement paths via dead-reckoning, calibrated magnetometer and gyroscope data is required. More information can be found [here](https://github.com/OakAlice/IntegratedCollarAnalysis/tree/main). Otherwise, GPS can be used to give general location infomation. *[In Progress]*

Worked example provided. Example data sourced from [Vehkaoja et al., 2020](https://www.sciencedirect.com/science/article/pii/S2352340922000348) but only a very small amount of data commited to Git (otherwise too big).

---
## Folder structure
*Have to fill this in*

## Using this workflow
*Have to fill this in*

**Notes**
- Models are weighted by class prevelance. You may want to change the way they are weighted, or initialise some kind of balancing between classes.
