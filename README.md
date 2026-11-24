# aniML

Accelerometer-based animal behaviour classification is a fast-growing biologging technique but one that is often underutilised due to technical complexity of designing an appropriate machine learning workflow. To address this gap, the **aniML** R-package is intended as a user-friendly, ecologist-focused, end-to-end pipeline for accelerometer-based animal behaviour supervised machine learning classification with specific functionality for small datasets. 

![Workflow](/Figures/Workflow.png)

1. Initial data exploration scripts used to determine optimal behavioural clusters.
2. Synthetic data augmentation to increase counts of the minority classes.
3. Machine learning scripts used for tuning and testing an optimised classifier.
4. Sequence-informed post-processing.

Worked example provided. Example data sourced from one of my collaborations, [Sparkes et al., 2025](https://www.mdpi.com/2076-2615/15/24/3537), looking at the ground-traverse behaviour of koalas.

---
## Instructions and guides
Detailed tutorials on understanding accelerometer-based animal behaviour classification, machine learning for small datasets, and how to use this package specifically can be found [here](/Guides/01.md). 
