# How aniML works

## How accelerometers can measure behaviour
Accelerometers are devices that measure instantaneous accelerations, including gravity, and store this as a time-series record. By inspecting the recorded accelerations, the orientation and movement of the device can be reconstructed and understood. As each unique pattern of movement will result in unique acceleration records, the specific initial movements can be determined. Accelerometers in sports-watches enable the counting of steps and tracking of exercise effort. The same concept applies to animal tracking.

Accelerometer-based animal behaviour classification was first trialled with Adelia penguins in the early 2000s (Yoda et al., 2021) where the changes in measurement of gravity enabled the body orientation of the penguins to be differentiated and therefore land (upright) vs water (horizontal) behaviours differentiated (Figure 1). 

<p align="center">
  <img src="Figures/penguins.png" alt="Penguins" width="50%">
</p>
<p align="center"><em>Fig 1: The change in accelerometer axis measuring dominant "gravity" acceleration (direction denoted by yellow arrow), can be used to infer the body posture and therefore the behaviour of the penguin.</em></p>

Since then, accelerometers have been used on hundreds of species to understand increasingly fine-scale behaviours. Some behaviours (e.g., the postural change in the penguin example above) can be differentiated with simple threshold rules (e.g., if Y > Z, then horizontal, else, vertical...) but more complex behavioural states require more complex rules. Additionally, as devices are often sampling for weeks or months at a time, there is far too much data to be assessed by a human. Instead, machine learning (ML) is used to automate the classification process.

## Machine learning 
ML is when the algorithm learns the classification rules directly from the data (rather than having been explicitly defined by humans, as in the threshold example). In this case, algorithms are "trained" on ground-truthed data where labels have been applied, thereby giving the model an example to learn from.

## Testing
One of the most important stages of machine learning is testing the performance. An untested model is an unknown model. 
To learn more about model testing, see [Wilson et al., 2025](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/1365-2656.70054). 

<p align="center">
  <img src="Figures/general_workflow.png" alt="General ML usage" width="80%">
</p>
<p align="center"><em>Fig 2: Labelled data is partitioned into training, tuning, and testing portions to build and validate a ML classification model. Finally, this model is applied to the unlabelled and unknown data from deployment.</em></p>
