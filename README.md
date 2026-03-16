# SmallAniMLs

This repository contains a minimal pipeline for developing a supervised machine learning animal behaviour classifier for small datasets. Works for larger datasets as well. 

![Workflow](/Figures/Workflow.png)

1. Initial data exploration scripts used to determine optimal behavioural clusters. *[In Progress]*
2. Synthetic data augmentation/boosting to increase counts of the minority classes. *[In Progress]*
3. Machine learning scripts used for training, validating, and testing classifier (includ. data formatting, feature extraction, train-test splitting, and hyperparameter tuning for a limited set of hyperparameters for either multi-class Random Forest or binary-class SVMs). *[Complete]*
4. Prediction results can be plugged into post-processing workflow developed [here](https://github.com/OakAlice/PostProcessing). *[Complete]*
5. To reconstruct exact movement paths via dead-reckoning, calibrated magnetometer and gyroscope data is required. More information can be found [here](https://github.com/OakAlice/IntegratedCollarAnalysis/tree/main). Otherwise, GPS can be used to give general location infomation. *[In Progress]*

Worked example provided. Example data sourced from one of my collaborations --- [Sparkes et al., 2025](https://www.mdpi.com/2076-2615/15/24/3537) --- looking at the ground-traverse behaviour of koalas.

---
## Folder structure
*Have to fill this in*

## Using this workflow
*Have to fill this in*

**Notes**
- Models are weighted by class prevelance. You may want to change the way they are weighted, or initialise some kind of balancing between classes.
