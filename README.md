# 🧠 A Neurocomputational Model of Nicotine Addiction

A computational neuroscience project that models the development of **nicotine addiction** using **reinforcement learning, nonlinear dynamical systems, dopamine signaling, and neural action-selection mechanisms**.

## Overview

Addiction is a complex phenomenon involving biological, psychological, and behavioral mechanisms.

This project implements a **neurocomputational model of nicotine addiction** that combines two major theoretical frameworks:

* **Reinforcement Learning / Reward-Based Learning**
* **Opponent-Process Theory**

The model investigates how repeated nicotine consumption can gradually transform behavior from **impulsive and exploratory actions** into **compulsive behavior**.

The implementation was developed independently because the original implementation was not available. Due to the nonlinear and stochastic nature of the model, multiple simulation runs are required to evaluate its behavior reliably.

## Model Architecture

The proposed model consists of several interacting components:



The model integrates an **Action Selection module** based on the cortex–basal ganglia–thalamus loop with a **Dopamine Signaling module** responsible for reward evaluation and prediction error.

## Main Components

### 1. Action Selection Module

The Action Selection module models behavioral decision-making through two interacting loops:

* **Premotor Loop** — planning and preparation of an action
* **Motor Loop** — execution of the selected action

These loops represent the **Cortex–Basal Ganglia–Thalamus (C-BG-TH)** circuitry.

The model uses nonlinear activation functions and internal neural state variables to determine the final behavioral output.

The final action is determined from the activity of the motor pathway, allowing the system to select behaviors such as:

```text
Smoke
Not Smoke
Undecided
```

### 2. Dopamine Signaling Module

The dopamine subsystem models how nicotine-related stimuli influence reward processing and behavioral learning.

It contains two main components:

#### Action Evaluation

Evaluates the current action based on nicotine presence and dopamine activation.

#### Value Assignment

Assigns a value to the performed action and computes the **Reward Prediction Error (RPE)**:

```text
δ(k) = Received Reward + Future Expected Value - Current Value
```

The prediction error represents the difference between the expected and received reward and drives the learning process.

### 3. N-S-C Dynamics

The N-S-C subsystem models the internal dynamics associated with nicotine processing.

It consists of three nonlinear state variables:

```text
n(k)
s(k)
c(k)
```

These variables evolve over time based on nicotine input and their interactions.

The output of this subsystem contributes to the dopamine activation signal, creating a connection between **nicotine exposure, physiological dynamics, dopamine signaling, and reward learning**.

## Reinforcement Learning Mechanism

The central learning mechanism is based on the idea that actions followed by rewards become increasingly likely to be repeated.

Initially, the reward associated with smoking is very small:

```text
r_i = 0.01
```

Each time the smoking action is selected, the reward increases until reaching a maximum value:

```text
0.01 → 0.02 → 0.04 → ... → 1.0
```

This progressively increases the learned value of smoking and can eventually lead to compulsive action selection.

The model therefore captures a transition from:

```text
Exploration
     ↓
Reward Learning
     ↓
Increased Smoking Value
     ↓
Repeated Smoking
     ↓
Compulsive Behavior
```

## Key Parameters

Some of the main model parameters include:

| Parameter | Description                             | Value |
| --------- | --------------------------------------- | ----: |
| λ         | Premotor/Motor self-feedback            |   0.5 |
| β         | Premotor → Motor influence              |  0.03 |
| a         | Activation-function sharpness           |     3 |
| μDA       | Dopamine learning rate                  |   0.1 |
| ηc        | Cortex → Premotor learning rate         |   0.1 |
| ηv        | Stimulus-value learning rate            |   0.1 |
| ηrpm      | Ventral → dorsal striatum learning rate |   0.1 |
| θDA       | Tonic dopamine threshold                |  0.01 |
| μ         | N-S-C update rate                       |   0.1 |
| τn        | n time constant                         |  0.25 |
| τs        | s time constant                         |     1 |
| τc        | c time constant                         |     2 |

The complete parameter set is provided in the project report.


## Simulation

The model was evaluated through repeated stochastic simulations.

### Addiction Criterion

A simulation is considered to have reached an addictive state when the **smoking action is selected 20 consecutive times**.

The experiment consisted of:

```text
Number of runs:       50
Addicted runs:        20
Addiction rate:       40%
Mean trials to addiction: 346
Standard deviation:   265.7
```

These results suggest that the implemented model can reproduce the gradual development of addictive behavior under the defined behavioral criterion.

## Reward Prediction Error

The Reward Prediction Error (δ) provides an important view of the learning process.

### Smoker

During successful addiction development:

1. The system initially produces a negative prediction error.
2. δ rapidly increases as smoking produces rewards larger than expected.
3. The prediction error subsequently decreases.
4. δ approaches zero as the agent learns the value of smoking.

This behavior represents the transition from **surprise-driven learning to stable reward prediction**.

### Non-Smoker

In simulations where addiction does not develop, the prediction error remains more variable.

The absence of convergence toward zero reflects continued exploration and the inability of the system to establish a stable compulsive smoking behavior.

## Theoretical Background

The model combines two complementary perspectives on addiction.

### Reinforcement Learning

Repeated reward strengthens the value of an action, increasing the probability that the action will be selected again.

### Opponent-Process Theory

An initially pleasurable stimulus can be followed by an opposing negative emotional state. Over time, behavior may therefore become motivated not only by obtaining pleasure, but also by avoiding the negative state associated with withdrawal or craving.

Together, these mechanisms provide a computational interpretation of how repeated nicotine exposure can produce persistent behavioral patterns.

## Implementation

The simulation was implemented independently based on the mathematical formulation presented in the model.

Because the system is:

* nonlinear
* stochastic
* dynamically coupled
* dependent on learned parameters

individual simulation runs can produce different trajectories.

Therefore, repeated experiments and statistical analysis are important when evaluating the model.

## Project Goals

The main goals of this project are:

* Model nicotine addiction using computational neuroscience.
* Combine reinforcement learning with biological neural dynamics.
* Simulate dopamine-based reward learning.
* Model action selection through cortico-striatal circuits.
* Investigate the transition from impulsive to compulsive behavior.
* Analyze reward prediction error during addiction development.
* Evaluate addiction development through repeated stochastic simulations.


## References & Theoretical Foundations

The model is based on concepts from:

* Computational neuroscience
* Reinforcement learning
* Dopamine-based reward systems
* Cortex–basal ganglia–thalamus action selection
* Opponent-process theory
* Nonlinear dynamical systems
* Neural plasticity

## Author

**Parsa Darban**

Computational Modeling of Physiological Systems — Spring 2025

