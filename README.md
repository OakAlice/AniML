# AniML

This repository contains a pipeline for developing a supervised machine learning animal behaviour classifier, with added functionality for small datasets specifically. 

![Workflow](/Figures/Workflow.png)

1. Initial data exploration scripts used to determine optimal behavioural clusters.
2. Synthetic data augmentation to increase counts of the minority classes.
3. Machine learning scripts used for tuning and testing a classifier.
4. Sequence-informed post-processing.

Worked example provided. Example data sourced from one of my collaborations --- [Sparkes et al., 2025](https://www.mdpi.com/2076-2615/15/24/3537) --- looking at the ground-traverse behaviour of koalas.

---
## Using this workflow
*Have to fill this in*

**Notes**
- Models are weighted by class prevelance. You may want to change the way they are weighted, or initialise some kind of balancing between classes.
